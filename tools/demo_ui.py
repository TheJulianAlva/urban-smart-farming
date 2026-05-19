"""
╔══════════════════════════════════════════════════════════════╗
║       Urban Smart Farming — Demo UI para Presentación        ║
║                                                              ║
║  Dos ventanas de navegador:                                  ║
║    /view    → Proyección al público (planta animada)         ║
║    /control → Panel del operador (botones de escenario)      ║
╚══════════════════════════════════════════════════════════════╝

USO:
  1. Asegúrate de que el backend esté corriendo:
       cd backend && uvicorn app.main:app --reload

  2. Edita DEVICE_UUID con el UUID de tu Device en Supabase.

  3. Ejecuta:
       cd tools && python demo_ui.py

  Se abrirán dos ventanas del navegador automáticamente.
"""

import json
import os
import random
import socketserver
import sys
import threading
import time
import webbrowser
from datetime import datetime
from http.server import BaseHTTPRequestHandler
from pathlib import Path

# ──────────────────────────────────────────────────────────────
# CONFIGURACIÓN
# ──────────────────────────────────────────────────────────────
DEVICE_UUID   = "0e38f2f7-5093-41d0-bbbe-0f97a55e69f1"  # ← UUID de Supabase
DEMO_PORT     = 8765
MQTT_INTERVAL = 12  # segundos entre publicaciones

# Cargar credenciales desde backend/.env (mismo patrón que simulate_esp32.py)
_env_path = Path(__file__).parent.parent / "backend" / ".env"
if _env_path.exists():
    with open(_env_path) as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                key, _, value = line.partition("=")
                os.environ.setdefault(key.strip(), value.strip())

MQTT_HOST = os.environ.get("MQTT_BROKER_HOST", "")
MQTT_PORT = int(os.environ.get("MQTT_BROKER_PORT", "8883"))
MQTT_USER = os.environ.get("MQTT_USERNAME", "")
MQTT_PASS = os.environ.get("MQTT_PASSWORD", "")
TOPIC = f"usf/telemetria/{DEVICE_UUID}"

# ──────────────────────────────────────────────────────────────
# ESTADOS
# ──────────────────────────────────────────────────────────────
SCENARIOS = {
    "optimal":    {"label": "Estado Óptimo",   "color": "#22c55e",
                   "moisture": 70.0, "temperature": 22.0, "light": 75.0},
    "drought":    {"label": "Falta de Agua",   "color": "#d97706",
                   "moisture": 12.0, "temperature": 25.0, "light": 72.0},
    "irrigation": {"label": "Riego Activo",    "color": "#3b82f6",
                   "moisture": 25.0, "temperature": 23.0, "light": 70.0},
    "heat":       {"label": "Calor Extremo",   "color": "#ef4444",
                   "moisture": 35.0, "temperature": 38.0, "light": 95.0},
    "disease":    {"label": "Enfermedad",       "color": "#a855f7",
                   "moisture": 82.0, "temperature": 22.0, "light": 28.0},
}

IRRIGATION_RAMP = [25.0, 30.0, 40.0, 55.0, 70.0, 80.0]


# ──────────────────────────────────────────────────────────────
# ESTADO COMPARTIDO
# ──────────────────────────────────────────────────────────────
class DemoState:
    def __init__(self):
        self._lock       = threading.Lock()
        self.state       = "optimal"
        self.tick        = 0
        self.irr_idx     = 0
        self.moisture    = SCENARIOS["optimal"]["moisture"]
        self.temperature = SCENARIOS["optimal"]["temperature"]
        self.light       = SCENARIOS["optimal"]["light"]
        self.mqtt_log: list = []

    def set_state(self, new_state: str) -> bool:
        if new_state not in SCENARIOS:
            return False
        with self._lock:
            self.state   = new_state
            self.irr_idx = 0
        return True

    def compute_values(self):
        with self._lock:
            s  = self.state
            sc = SCENARIOS[s]
            if s == "irrigation":
                idx      = min(self.irr_idx, len(IRRIGATION_RAMP) - 1)
                moisture = IRRIGATION_RAMP[idx]
                if self.irr_idx < len(IRRIGATION_RAMP) - 1:
                    self.irr_idx += 1
                temp  = sc["temperature"]
                light = sc["light"]
            else:
                moisture = sc["moisture"]
                temp     = sc["temperature"]
                light    = sc["light"]
            self.moisture    = moisture
            self.temperature = temp
            self.light       = light
            self.tick       += 1
            return moisture, temp, light

    def push_log(self, entry: str):
        with self._lock:
            self.mqtt_log.append(entry)
            if len(self.mqtt_log) > 8:
                self.mqtt_log.pop(0)

    def as_dict(self) -> dict:
        with self._lock:
            return {
                "state":       self.state,
                "label":       SCENARIOS[self.state]["label"],
                "color":       SCENARIOS[self.state]["color"],
                "moisture":    round(self.moisture, 1),
                "temperature": round(self.temperature, 1),
                "light":       round(self.light, 1),
                "tick":        self.tick,
                "mqtt_log":    list(self.mqtt_log),
            }


# ──────────────────────────────────────────────────────────────
# PUBLICADOR MQTT
# ──────────────────────────────────────────────────────────────
class MQTTPublisher(threading.Thread):
    def __init__(self, state: DemoState):
        super().__init__(daemon=True)
        self.state = state

    def _build_client(self):
        import paho.mqtt.client as mqtt
        client = mqtt.Client(
            mqtt.CallbackAPIVersion.VERSION2,
            client_id=f"usf-demo-{random.randint(1000, 9999)}",
        )
        client.username_pw_set(MQTT_USER, MQTT_PASS)
        client.tls_set()

        def on_connect(client, userdata, flags, reason_code, properties):
            if reason_code.is_failure:
                print(f"[MQTT] Error de conexión: {reason_code}")
            else:
                print(f"[MQTT] Conectado a HiveMQ ✓")

        def on_disconnect(client, userdata, flags, reason_code, properties):
            if reason_code.is_failure:
                print(f"[MQTT] Desconectado: {reason_code}")

        def on_publish(client, userdata, mid, reason_code, properties):
            pass

        client.on_connect    = on_connect
        client.on_disconnect = on_disconnect
        client.on_publish    = on_publish
        return client

    def run(self):
        client = None
        if MQTT_HOST:
            try:
                client = self._build_client()
                client.connect(MQTT_HOST, MQTT_PORT, keepalive=60)
                client.loop_start()
                time.sleep(1.5)
            except Exception as e:
                print(f"[MQTT] No se pudo conectar: {e}. Modo visual sin MQTT.")
                client = None
        else:
            print("[MQTT] Sin credenciales — modo visual sin MQTT.")

        while True:
            m, t, l = self.state.compute_values()
            ts    = datetime.now().strftime("%H:%M:%S")
            entry = f"[{ts}] {self.state.state} | H:{m}% T:{t}°C L:{l}%"
            self.state.push_log(entry)

            if client:
                payload = json.dumps({"moisture": m, "temperature": t, "light": l})
                client.publish(TOPIC, payload, qos=1)
                print(f"[MQTT] {entry}")
            else:
                print(f"[Demo] {entry}")

            time.sleep(MQTT_INTERVAL)


# ──────────────────────────────────────────────────────────────
# HTML — PANTALLA DE VISUALIZACIÓN
# ──────────────────────────────────────────────────────────────
HTML_VIEW = """<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Urban Smart Farming — Demo</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
html,body{width:100%;height:100%;overflow:hidden;font-family:'Segoe UI',system-ui,sans-serif}
body{
  background:radial-gradient(ellipse at 50% 30%,#0d2a1a 0%,#050e08 100%);
  display:flex;flex-direction:column;align-items:center;justify-content:center;
  min-height:100vh;position:relative;transition:background 1.2s ease;
}

/* ── ESTADO BADGE ── */
#state-badge{
  position:absolute;top:32px;left:50%;transform:translateX(-50%);
  background:rgba(0,0,0,.45);backdrop-filter:blur(8px);
  border:2px solid var(--accent,#22c55e);border-radius:40px;
  padding:10px 36px;text-align:center;transition:border-color 0.8s;
}
#state-label{
  font-size:2rem;font-weight:800;color:#fff;letter-spacing:.04em;
  text-shadow:0 0 20px var(--accent,#22c55e);transition:color 0.8s,text-shadow 0.8s;
}
#state-sub{font-size:.95rem;color:rgba(255,255,255,.6);margin-top:2px}

/* ── ESCENA ── */
.plant-scene{
  position:relative;display:flex;flex-direction:column;
  align-items:center;justify-content:flex-end;
  width:340px;height:480px;
}

/* ── SOL ── */
.bg-sun{
  position:absolute;top:-20px;right:20px;
  width:90px;height:90px;border-radius:50%;
  background:radial-gradient(circle,#fde68a 30%,#fbbf24 60%,transparent 100%);
  box-shadow:0 0 40px #fbbf2466;opacity:.55;
  transition:width 1s,height 1s,opacity 1s,box-shadow 1s;
}

/* ── ONDAS DE CALOR ── */
.heat-waves{
  display:none;position:absolute;bottom:200px;left:50%;
  transform:translateX(-50%);width:220px;
}
.wave{
  height:3px;border-radius:2px;margin:9px 0;
  background:linear-gradient(90deg,transparent,#f97316aa,transparent);
  animation:shimmer 1.4s ease-in-out infinite;
}
.w1{width:160px;animation-delay:0s}
.w2{width:210px;animation-delay:.3s}
.w3{width:130px;animation-delay:.6s}
@keyframes shimmer{
  0%,100%{opacity:.2;transform:scaleX(.85)}
  50%{opacity:.85;transform:scaleX(1.1)}
}

/* ── LLUVIA ── */
.rain-container{
  position:absolute;top:0;left:50%;transform:translateX(-50%);
  width:200px;height:100%;pointer-events:none;overflow:hidden;
}
.raindrop{
  position:absolute;width:2px;height:16px;border-radius:50%;
  background:linear-gradient(to bottom,#93c5fd,#3b82f6);
  animation:fall 1s linear infinite;opacity:0;
}
@keyframes fall{
  0%{transform:translateY(-30px);opacity:.9}
  100%{transform:translateY(420px);opacity:0}
}

/* ── MACETA ── */
.pot{
  width:150px;height:105px;
  background:linear-gradient(160deg,#c2714f 0%,#8b4513 60%,#6b3410 100%);
  clip-path:polygon(6% 0%,94% 0%,100% 100%,0% 100%);
  border-radius:0 0 14px 14px;
  position:relative;flex-shrink:0;
  box-shadow:inset -8px 0 18px rgba(0,0,0,.4),0 8px 24px rgba(0,0,0,.5);
}
.pot-rim{
  position:absolute;top:-10px;left:-6px;right:-6px;height:14px;
  background:linear-gradient(180deg,#d4895a,#9c5a2d);
  border-radius:6px;
}
.soil{
  position:absolute;top:0;left:7%;width:86%;height:34px;
  background:#3b1e0a;border-radius:50% 50% 0 0;overflow:hidden;
  transition:background 2s ease;
}

/* ── GRIETAS ── */
.crack{display:none;position:absolute;background:#8b6355;height:1.5px;border-radius:1px}
.c1{width:26px;top:12px;left:22%;transform:rotate(28deg)}
.c2{width:18px;top:18px;left:58%;transform:rotate(-22deg)}

/* ── AGUA EN SUELO ── */
.wdrop{
  position:absolute;bottom:2px;border-radius:50%;
  background:radial-gradient(circle,#60a5fa88,#3b82f644);
  transition:opacity .6s;
}
.wd1{width:12px;height:6px;left:20%}
.wd2{width:8px;height:4px;left:55%}

/* ── TALLO ── */
.stem-wrap{
  width:14px;height:130px;margin:0 auto;
  position:relative;transform-origin:bottom center;
  transition:transform 1s ease,filter 1s ease;
}
.stem{
  width:100%;height:100%;
  background:linear-gradient(to right,#2d6a1f,#4cae31);
  border-radius:7px;
}

/* ── HOJAS ── */
.leaf{
  position:absolute;width:52px;height:24px;
  background:linear-gradient(120deg,#3d8b27,#6abf45);
  border-radius:50% 50% 50% 0;transition:filter 1s ease;
}
.leaf-l{left:-48px;top:42px;transform:rotate(-32deg);transform-origin:right center}
.leaf-r{left:14px;top:70px;transform:rotate(32deg) scaleX(-1);transform-origin:left center}

/* ── FLOR ── */
.flower{
  position:relative;width:0;height:0;
  margin-bottom:4px;transition:transform 1s ease;
}

/* ── PÉTALOS ── */
.petal{
  position:absolute;
  width:22px;height:48px;
  border-radius:50% 50% 40% 40%;
  background:linear-gradient(180deg,#fbbf24,#f97316);
  transform-origin:center bottom;
  left:-11px;top:-48px;
  transition:background 1s ease,transform 1s ease,filter 1s ease,opacity 1s ease;
}
/* outer ring: 8 pétalos cada 45° */
.or .p1{transform:rotate(0deg)}
.or .p2{transform:rotate(45deg)}
.or .p3{transform:rotate(90deg)}
.or .p4{transform:rotate(135deg)}
.or .p5{transform:rotate(180deg)}
.or .p6{transform:rotate(225deg)}
.or .p7{transform:rotate(270deg)}
.or .p8{transform:rotate(315deg)}
/* inner ring: más pequeños, rotados 22.5° */
.ir .petal{width:16px;height:36px;left:-8px;top:-36px;opacity:.85}
.ir .p1{transform:rotate(22.5deg)}
.ir .p2{transform:rotate(67.5deg)}
.ir .p3{transform:rotate(112.5deg)}
.ir .p4{transform:rotate(157.5deg)}
.ir .p5{transform:rotate(202.5deg)}
.ir .p6{transform:rotate(247.5deg)}
.ir .p7{transform:rotate(292.5deg)}
.ir .p8{transform:rotate(337.5deg)}

/* ── CENTRO ── */
.flower-center{
  position:absolute;width:34px;height:34px;border-radius:50%;
  background:radial-gradient(circle,#f59e0b 40%,#d97706 100%);
  left:-17px;top:-17px;
  box-shadow:0 0 16px #fbbf2488;
  transition:box-shadow 1s ease;z-index:2;
}

/* ── MANCHAS ENFERMEDAD ── */
.spot{
  display:none;position:absolute;border-radius:50%;z-index:3;
  background:radial-gradient(circle,#78350fdd,#3b1c0088);
}
.s1{width:16px;height:11px;top:-45px;left:-30px}
.s2{width:11px;height:9px;top:-20px;left:8px}
.s3{width:20px;height:13px;top:-35px;left:-5px}

/* ── ANIMACIONES GLOBALES ── */
@keyframes sway{
  0%,100%{transform:rotate(0deg)}
  25%{transform:rotate(3.5deg)}
  75%{transform:rotate(-3.5deg)}
}
@keyframes sway-heat{
  0%,100%{transform:rotate(0deg)}
  50%{transform:rotate(-5deg)}
}
@keyframes drip{
  0%{transform:translateY(0);opacity:.7}
  100%{transform:translateY(10px);opacity:0}
}
@keyframes pump-blink{50%{opacity:.3}}

/* ════════════════════════════════════════
   ESTADOS — todo controlado por data-state
   ════════════════════════════════════════ */

/* OPTIMAL */
[data-state="optimal"]{background:radial-gradient(ellipse at 50% 30%,#0d2a1a 0%,#050e08 100%)}
[data-state="optimal"] .stem-wrap{animation:sway 4s ease-in-out infinite}
[data-state="optimal"] .petal{background:linear-gradient(180deg,#fde68a,#f97316)}
[data-state="optimal"] .flower-center{box-shadow:0 0 28px #fbbf24bb}
[data-state="optimal"] .bg-sun{opacity:.55}
[data-state="optimal"] .wdrop{opacity:1;animation:drip 2.5s ease-in-out infinite}
[data-state="optimal"] .wd2{animation-delay:.8s}
[data-state="optimal"] .soil{background:#3b1e0a}
[data-state="optimal"] #state-badge{--accent:#22c55e}

/* DROUGHT */
[data-state="drought"]{background:radial-gradient(ellipse at 50% 20%,#2a1500 0%,#0e0500 100%)}
[data-state="drought"] .stem-wrap{transform:rotate(5deg);filter:saturate(.5)}
[data-state="drought"] .leaf{filter:saturate(.25) brightness(.7)}
[data-state="drought"] .petal{
  background:linear-gradient(180deg,#d97706aa,#92400ecc);
  filter:saturate(.5) brightness(.8);
}
[data-state="drought"] .flower{transform:scale(0.82) translateY(6px)}
[data-state="drought"] .soil{background:#b8a090}
[data-state="drought"] .crack{display:block}
[data-state="drought"] .wdrop{opacity:0}
[data-state="drought"] .bg-sun{opacity:.85;width:110px;height:110px;box-shadow:0 0 55px #f9731666}
[data-state="drought"] #state-badge{--accent:#d97706}

/* IRRIGATION */
[data-state="irrigation"]{background:radial-gradient(ellipse at 50% 30%,#0a1f35 0%,#030b14 100%)}
[data-state="irrigation"] .stem-wrap{animation:sway 4s ease-in-out infinite}
[data-state="irrigation"] .petal{background:linear-gradient(180deg,#fde68a,#f97316)}
[data-state="irrigation"] .soil{background:#3b1e0a}
[data-state="irrigation"] .wdrop{opacity:0}
[data-state="irrigation"] .bg-sun{opacity:.3}
[data-state="irrigation"] #state-badge{--accent:#3b82f6}

/* HEAT */
[data-state="heat"]{background:radial-gradient(ellipse at 50% 20%,#3b0000 0%,#150000 100%)}
[data-state="heat"] .stem-wrap{transform:rotate(-3deg);filter:saturate(.65)}
[data-state="heat"] .leaf{filter:saturate(.5) brightness(.75)}
[data-state="heat"] .petal{
  background:linear-gradient(180deg,#fca5a5,#ef4444);
  transform-origin:center bottom;
}
[data-state="heat"] .or .p1{transform:rotate(0deg) scale(.72)}
[data-state="heat"] .or .p2{transform:rotate(45deg) scale(.72)}
[data-state="heat"] .or .p3{transform:rotate(90deg) scale(.72)}
[data-state="heat"] .or .p4{transform:rotate(135deg) scale(.72)}
[data-state="heat"] .or .p5{transform:rotate(180deg) scale(.72)}
[data-state="heat"] .or .p6{transform:rotate(225deg) scale(.72)}
[data-state="heat"] .or .p7{transform:rotate(270deg) scale(.72)}
[data-state="heat"] .or .p8{transform:rotate(315deg) scale(.72)}
[data-state="heat"] .ir .p1{transform:rotate(22.5deg) scale(.72)}
[data-state="heat"] .ir .p2{transform:rotate(67.5deg) scale(.72)}
[data-state="heat"] .ir .p3{transform:rotate(112.5deg) scale(.72)}
[data-state="heat"] .ir .p4{transform:rotate(157.5deg) scale(.72)}
[data-state="heat"] .ir .p5{transform:rotate(202.5deg) scale(.72)}
[data-state="heat"] .ir .p6{transform:rotate(247.5deg) scale(.72)}
[data-state="heat"] .ir .p7{transform:rotate(292.5deg) scale(.72)}
[data-state="heat"] .ir .p8{transform:rotate(337.5deg) scale(.72)}
[data-state="heat"] .bg-sun{opacity:1;width:130px;height:130px;box-shadow:0 0 70px #fbbf24cc,0 0 120px #ef444466}
[data-state="heat"] .heat-waves{display:block}
[data-state="heat"] .soil{background:#b89070}
[data-state="heat"] .wdrop{opacity:0}
[data-state="heat"] #state-badge{--accent:#ef4444}

/* DISEASE */
[data-state="disease"]{background:radial-gradient(ellipse at 50% 30%,#1a0d2e 0%,#080410 100%)}
[data-state="disease"] .flower{transform:rotate(-10deg)}
[data-state="disease"] .stem-wrap{filter:saturate(.3);transform:rotate(3deg)}
[data-state="disease"] .leaf{filter:saturate(.15) brightness(.6)}
[data-state="disease"] .petal{
  background:linear-gradient(180deg,#a16207cc,#78350fcc);
  filter:saturate(.35);
}
[data-state="disease"] .or{transform:rotate(15deg)}
[data-state="disease"] .ir{transform:rotate(-10deg)}
[data-state="disease"] .flower-center{background:radial-gradient(circle,#92400e,#78350f);box-shadow:0 0 8px #78350f44}
[data-state="disease"] .spot{display:block}
[data-state="disease"] .bg-sun{opacity:.2}
[data-state="disease"] #state-badge{--accent:#a855f7}

/* ── PANEL DE SENSORES ── */
#sensor-panel{
  position:absolute;bottom:28px;left:50%;transform:translateX(-50%);
  background:rgba(0,0,0,.5);backdrop-filter:blur(10px);
  border-radius:20px;padding:18px 36px;
  display:flex;gap:36px;border:1px solid rgba(255,255,255,.1);
}
.sensor-row{display:flex;align-items:center;gap:10px;min-width:180px}
.sensor-icon{font-size:1.4rem}
.sensor-label{color:rgba(255,255,255,.65);font-size:.85rem;width:70px}
.bar-track{
  flex:1;height:8px;background:rgba(255,255,255,.12);
  border-radius:4px;overflow:hidden;min-width:80px;
}
.bar-fill{height:100%;border-radius:4px;transition:width 1.2s ease,background 1s ease;width:0%}
.sensor-val{color:#fff;font-weight:700;font-size:1rem;min-width:52px;text-align:right}

/* Bar colors por estado */
[data-state="optimal"]    .bar-fill{background:linear-gradient(90deg,#22c55e,#16a34a)}
[data-state="drought"]    .bar-fill{background:linear-gradient(90deg,#d97706,#92400e)}
[data-state="irrigation"] .bar-fill{background:linear-gradient(90deg,#3b82f6,#1d4ed8)}
[data-state="heat"]       .bar-fill{background:linear-gradient(90deg,#f97316,#ef4444)}
[data-state="disease"]    .bar-fill{background:linear-gradient(90deg,#a855f7,#7c3aed)}

/* ── LOGO ── */
#logo{
  position:absolute;top:28px;left:36px;
  color:rgba(255,255,255,.35);font-size:.8rem;letter-spacing:.15em;
  text-transform:uppercase;
}

/* ── PUMP BADGE ── */
#pump-badge{
  display:none;position:absolute;top:28px;right:36px;
  background:rgba(59,130,246,.2);border:1px solid #3b82f6;
  border-radius:20px;padding:6px 16px;color:#93c5fd;font-size:.85rem;font-weight:600;
}
[data-state="irrigation"] #pump-badge{display:block;animation:pump-blink .9s ease-in-out infinite}
</style>
</head>
<body data-state="optimal">

<div id="logo">🌱 Urban Smart Farming</div>
<div id="pump-badge">💧 Bomba Activa</div>

<div id="state-badge">
  <div id="state-label">Estado Óptimo</div>
  <div id="state-sub">Maceta Inteligente</div>
</div>

<div class="plant-scene">
  <div class="bg-sun"></div>
  <div class="heat-waves">
    <div class="wave w1"></div>
    <div class="wave w2"></div>
    <div class="wave w3"></div>
  </div>
  <div class="rain-container" id="rain-container"></div>

  <div class="plant-wrapper">
    <!-- Flor -->
    <div class="flower" id="flower">
      <div class="petal-ring or">
        <div class="petal p1"></div><div class="petal p2"></div>
        <div class="petal p3"></div><div class="petal p4"></div>
        <div class="petal p5"></div><div class="petal p6"></div>
        <div class="petal p7"></div><div class="petal p8"></div>
      </div>
      <div class="petal-ring ir">
        <div class="petal p1"></div><div class="petal p2"></div>
        <div class="petal p3"></div><div class="petal p4"></div>
        <div class="petal p5"></div><div class="petal p6"></div>
        <div class="petal p7"></div><div class="petal p8"></div>
      </div>
      <div class="flower-center"></div>
      <div class="spot s1"></div>
      <div class="spot s2"></div>
      <div class="spot s3"></div>
    </div>

    <!-- Tallo y hojas -->
    <div class="stem-wrap">
      <div class="stem"></div>
      <div class="leaf leaf-l"></div>
      <div class="leaf leaf-r"></div>
    </div>
  </div>

  <!-- Maceta -->
  <div class="pot">
    <div class="pot-rim"></div>
    <div class="soil">
      <div class="crack c1"></div>
      <div class="crack c2"></div>
      <div class="wdrop wd1"></div>
      <div class="wdrop wd2"></div>
    </div>
  </div>
</div>

<!-- Panel de sensores -->
<div id="sensor-panel">
  <div class="sensor-row">
    <span class="sensor-icon">💧</span>
    <span class="sensor-label">Humedad</span>
    <div class="bar-track"><div class="bar-fill" id="bar-moisture"></div></div>
    <span class="sensor-val" id="val-moisture">--</span>
  </div>
  <div class="sensor-row">
    <span class="sensor-icon">🌡️</span>
    <span class="sensor-label">Temp.</span>
    <div class="bar-track"><div class="bar-fill" id="bar-temp"></div></div>
    <span class="sensor-val" id="val-temp">--</span>
  </div>
  <div class="sensor-row">
    <span class="sensor-icon">☀️</span>
    <span class="sensor-label">Luz</span>
    <div class="bar-track"><div class="bar-fill" id="bar-light"></div></div>
    <span class="sensor-val" id="val-light">--</span>
  </div>
</div>

<script>
function setBar(id, val, max, unit) {
  const pct = Math.min(val / max * 100, 100);
  document.getElementById('bar-' + id).style.width = pct + '%';
  document.getElementById('val-' + id).textContent = val.toFixed(1) + unit;
}

function syncRain(state) {
  const c = document.getElementById('rain-container');
  if (state === 'irrigation') {
    if (!c.children.length) {
      for (let i = 0; i < 16; i++) {
        const d = document.createElement('div');
        d.className = 'raindrop';
        d.style.left = (Math.random() * 110 - 5) + '%';
        d.style.animationDelay = (Math.random() * 1.5) + 's';
        d.style.animationDuration = (0.7 + Math.random() * 0.6) + 's';
        c.appendChild(d);
      }
    }
  } else {
    c.innerHTML = '';
  }
}

async function poll() {
  try {
    const r = await fetch('/api/state');
    const d = await r.json();
    document.body.dataset.state = d.state;
    document.getElementById('state-label').textContent = d.label;
    setBar('moisture', d.moisture,    100, '%');
    setBar('temp',     d.temperature,  50, '°C');
    setBar('light',    d.light,       100, '%');
    syncRain(d.state);
  } catch(e) {}
}

poll();
setInterval(poll, 2000);
</script>
</body>
</html>"""


# ──────────────────────────────────────────────────────────────
# HTML — PANEL DE CONTROL
# ──────────────────────────────────────────────────────────────
HTML_CONTROL = """<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>Control — Demo USF</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{background:#0f172a;color:#f1f5f9;font-family:'Segoe UI',system-ui,sans-serif;
     padding:28px;min-height:100vh}
h1{font-size:1.5rem;font-weight:800;color:#94a3b8;letter-spacing:.06em;
   text-transform:uppercase;margin-bottom:6px}
.subtitle{color:#475569;font-size:.85rem;margin-bottom:28px}

/* Botones */
#btn-grid{display:grid;grid-template-columns:repeat(5,1fr);gap:14px;margin-bottom:32px}
.btn-scenario{
  padding:22px 8px;border:2px solid transparent;border-radius:14px;
  font-size:1rem;font-weight:700;cursor:pointer;color:#fff;
  transition:all .25s ease;opacity:.55;line-height:1.4;
}
.btn-scenario:hover{opacity:.8;transform:translateY(-2px)}
.btn-scenario.active{
  opacity:1;transform:scale(1.05);
  box-shadow:0 0 24px currentColor,0 4px 20px rgba(0,0,0,.4);
  border-color:rgba(255,255,255,.25);
}
.btn-optimal   {background:#166534;color:#bbf7d0}
.btn-drought   {background:#92400e;color:#fed7aa}
.btn-irrigation{background:#1e40af;color:#bfdbfe}
.btn-heat      {background:#991b1b;color:#fecaca}
.btn-disease   {background:#581c87;color:#e9d5ff}
.btn-icon{font-size:2rem;display:block;margin-bottom:8px}

/* Valores actuales */
#current-values{
  display:flex;gap:0;margin-bottom:28px;
  background:#1e293b;border-radius:14px;overflow:hidden;
}
.cv-item{flex:1;padding:18px;text-align:center;border-right:1px solid #334155}
.cv-item:last-child{border-right:none}
.cv-icon{font-size:1.6rem;display:block;margin-bottom:6px}
.cv-label{font-size:.75rem;color:#64748b;text-transform:uppercase;letter-spacing:.08em}
.cv-val{font-size:2rem;font-weight:800;margin-top:4px;transition:color .5s}

/* Log MQTT */
#mqtt-log{background:#1e293b;border-radius:14px;padding:20px}
#mqtt-log h3{font-size:.85rem;color:#64748b;text-transform:uppercase;
             letter-spacing:.08em;margin-bottom:12px}
#log-list{list-style:none;padding:0}
#log-list li{
  font-family:'Cascadia Code','Consolas',monospace;font-size:.82rem;
  color:#94a3b8;padding:7px 0;border-bottom:1px solid #334155;
  display:flex;gap:8px;align-items:center;
}
#log-list li:last-child{border-bottom:none}
.log-dot{width:7px;height:7px;border-radius:50%;background:#22c55e;flex-shrink:0}

/* Status bar */
#status-bar{
  position:fixed;bottom:0;left:0;right:0;
  background:#0f172a;border-top:1px solid #1e293b;
  padding:10px 28px;display:flex;gap:20px;align-items:center;
  font-size:.8rem;color:#475569;
}
.status-dot{width:8px;height:8px;border-radius:50%;background:#22c55e;animation:pulse 2s infinite}
@keyframes pulse{0%,100%{opacity:1}50%{opacity:.4}}
</style>
</head>
<body>

<h1>🌱 Urban Smart Farming</h1>
<p class="subtitle">Panel de Control — Presentación en vivo</p>

<div id="btn-grid">
  <button class="btn-scenario btn-optimal active" onclick="setState('optimal')">
    <span class="btn-icon">🌸</span>Estado Óptimo
  </button>
  <button class="btn-scenario btn-drought" onclick="setState('drought')">
    <span class="btn-icon">🌵</span>Falta de Agua
  </button>
  <button class="btn-scenario btn-irrigation" onclick="setState('irrigation')">
    <span class="btn-icon">💧</span>Riego Activo
  </button>
  <button class="btn-scenario btn-heat" onclick="setState('heat')">
    <span class="btn-icon">🔥</span>Calor Extremo
  </button>
  <button class="btn-scenario btn-disease" onclick="setState('disease')">
    <span class="btn-icon">🍂</span>Enfermedad
  </button>
</div>

<div id="current-values">
  <div class="cv-item">
    <span class="cv-icon">💧</span>
    <div class="cv-label">Humedad del Suelo</div>
    <div class="cv-val" id="cv-moisture">--</div>
  </div>
  <div class="cv-item">
    <span class="cv-icon">🌡️</span>
    <div class="cv-label">Temperatura</div>
    <div class="cv-val" id="cv-temp">--</div>
  </div>
  <div class="cv-item">
    <span class="cv-icon">☀️</span>
    <div class="cv-label">Luz</div>
    <div class="cv-val" id="cv-light">--</div>
  </div>
</div>

<div id="mqtt-log">
  <h3>Publicaciones MQTT recientes</h3>
  <ul id="log-list"><li><span class="log-dot"></span>Esperando datos...</li></ul>
</div>

<div id="status-bar">
  <div class="status-dot"></div>
  <span id="status-text">Conectando...</span>
  <span style="margin-left:auto">Puerto 8765 · Tópico: <code id="topic-display"></code></span>
</div>

<script>
const STATE_COLORS = {
  optimal:'#22c55e', drought:'#d97706',
  irrigation:'#3b82f6', heat:'#ef4444', disease:'#a855f7'
};

async function setState(s) {
  try {
    await fetch('/api/set-state', {
      method: 'POST',
      headers: {'Content-Type':'application/json'},
      body: JSON.stringify({state: s})
    });
  } catch(e) {}
}

function updateActiveBtn(s) {
  document.querySelectorAll('.btn-scenario').forEach(b => b.classList.remove('active'));
  const btn = document.querySelector('.btn-' + s);
  if (btn) btn.classList.add('active');
}

async function poll() {
  try {
    const r = await fetch('/api/state');
    const d = await r.json();

    updateActiveBtn(d.state);
    const c = STATE_COLORS[d.state] || '#94a3b8';

    const setVal = (id, v, unit) => {
      const el = document.getElementById(id);
      el.textContent = v.toFixed(1) + unit;
      el.style.color = c;
    };
    setVal('cv-moisture', d.moisture,    '%');
    setVal('cv-temp',     d.temperature, '°C');
    setVal('cv-light',    d.light,       '%');

    const ul = document.getElementById('log-list');
    if (d.mqtt_log && d.mqtt_log.length) {
      ul.innerHTML = d.mqtt_log.slice().reverse()
        .map(e => `<li><span class="log-dot"></span>${e}</li>`).join('');
    }

    document.getElementById('status-text').textContent =
      `Estado: ${d.label} · Tick #${d.tick}`;
    document.getElementById('topic-display').textContent =
      'usf/telemetria/...';
  } catch(e) {
    document.getElementById('status-text').textContent = 'Sin conexión con el servidor demo';
  }
}

poll();
setInterval(poll, 2000);
</script>
</body>
</html>"""


# ──────────────────────────────────────────────────────────────
# HTTP HANDLER
# ──────────────────────────────────────────────────────────────
class DemoHTTPHandler(BaseHTTPRequestHandler):
    demo_state: DemoState = None  # inyectado en main()

    def log_message(self, format, *args):
        pass  # silenciar log de acceso

    def _send(self, code: int, content_type: str, body: bytes):
        self.send_response(code)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        path = self.path.split("?")[0]
        if path in ("/", "/view"):
            self._send(200, "text/html; charset=utf-8", HTML_VIEW.encode())
        elif path == "/control":
            self._send(200, "text/html; charset=utf-8", HTML_CONTROL.encode())
        elif path == "/api/state":
            data = json.dumps(self.demo_state.as_dict())
            self._send(200, "application/json", data.encode())
        else:
            self._send(404, "text/plain", b"Not found")

    def do_POST(self):
        if self.path == "/api/set-state":
            length = int(self.headers.get("Content-Length", 0))
            body   = self.rfile.read(length)
            try:
                req   = json.loads(body)
                state = req.get("state", "")
                ok    = self.demo_state.set_state(state)
                if ok:
                    data = json.dumps(self.demo_state.as_dict())
                    self._send(200, "application/json", data.encode())
                else:
                    self._send(400, "application/json", b'{"error":"unknown state"}')
            except Exception:
                self._send(400, "application/json", b'{"error":"bad request"}')
        else:
            self._send(404, "text/plain", b"Not found")

    def do_OPTIONS(self):
        self._send(204, "text/plain", b"")


# ──────────────────────────────────────────────────────────────
# MAIN
# ──────────────────────────────────────────────────────────────
def main():
    if sys.platform == "win32":
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")

    print("=" * 60)
    print("  Urban Smart Farming — Demo UI")
    print("=" * 60)

    state = DemoState()
    DemoHTTPHandler.demo_state = state

    # Publicador MQTT en background
    publisher = MQTTPublisher(state)
    publisher.start()

    # Servidor HTTP con soporte multi-hilo (dos tabs en paralelo)
    socketserver.TCPServer.allow_reuse_address = True
    server = socketserver.ThreadingTCPServer(("", DEMO_PORT), DemoHTTPHandler)

    server_thread = threading.Thread(target=server.serve_forever, daemon=True)
    server_thread.start()

    view_url    = f"http://localhost:{DEMO_PORT}/view"
    control_url = f"http://localhost:{DEMO_PORT}/control"

    print(f"\n  Pantalla de proyección : {view_url}")
    print(f"  Panel de control       : {control_url}")
    print(f"\n  Tópico MQTT: {TOPIC}")
    print(f"  Intervalo  : {MQTT_INTERVAL} s")
    print("\n  Ctrl+C para salir\n")

    time.sleep(0.9)
    webbrowser.open(view_url)
    time.sleep(0.4)
    webbrowser.open(control_url)

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n[Demo] Cerrando...")
        server.shutdown()


if __name__ == "__main__":
    main()
