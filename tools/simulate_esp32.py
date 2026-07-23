"""
╔══════════════════════════════════════════════════════════════╗
║          Urban Smart Farming — Simulador ESP32 MQTT          ║
║                                                              ║
║  Simula la telemetría de una maceta inteligente para         ║
║  testing del frontend y capturas de pantalla con datos       ║
║  reales fluyendo por el sistema completo.                    ║
╚══════════════════════════════════════════════════════════════╝

USO:
  1. Registra un Device desde la app (Wizard paso 2) o vía API:
       POST /api/v1/devices/register
       { "mac_address": "AA:BB:CC:DD:EE:FF", "crop_id": "<uuid>" }

  2. Copia el UUID del Device desde Supabase → tabla Device → columna id
     y pégalo en DEVICE_UUID más abajo.

  3. Arranca el backend:
       cd backend && uvicorn app.main:app --reload

  4. Ejecuta este script:
       cd tools && python simulate_esp32.py

  Dependencias:
       pip install paho-mqtt python-dotenv
"""

import json
import math
import os
import random
import sys
import time
from datetime import datetime
from pathlib import Path

# Forzar UTF-8 en Windows para soportar emojis en consola
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

# ──────────────────────────────────────────────────────────────
# CONFIGURACIÓN — Edita este valor con el UUID de tu Device
# ──────────────────────────────────────────────────────────────
DEVICE_UUID = "0e38f2f7-5093-41d0-bbbe-0f97a55e69f1"   # ← UUID de Supabase (Device.id)
INTERVAL_SECONDS = 5                             # Frecuencia de publicación
# ──────────────────────────────────────────────────────────────

# Cargar credenciales desde el .env del backend
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
# GENERADORES DE DATOS POR ESCENARIO
# ──────────────────────────────────────────────────────────────

def _jitter(base: float, spread: float) -> float:
    """Agrega variación aleatoria realista a un valor base."""
    return round(base + random.uniform(-spread, spread), 1)


def scenario_normal(tick: int) -> dict:
    """
    Valores saludables con variación suave tipo ola sinusoidal.
    Simula el comportamiento real de un cultivo bien cuidado.
    """
    wave = math.sin(tick * 0.3) * 3
    return {
        "moisture":    _jitter(65.0 + wave, 2.0),
        "temperature": _jitter(23.5, 0.5),
        "light":       _jitter(75.0 + wave * 0.3, 3.0),   # porcentaje (0-100%)
    }


def scenario_drought(tick: int) -> dict:
    """
    Humedad crítica — debería disparar alerta DROUGHT y bomba automática.
    moisture < min_moisture del perfil (típicamente 40-50%).
    """
    return {
        "moisture":    _jitter(22.0, 3.0),   # Muy por debajo del umbral
        "temperature": _jitter(24.0, 0.5),
        "light":       _jitter(75.0, 4.0),   # Luz normal
    }


def scenario_low_light(tick: int) -> dict:
    """
    Luz crítica — debería disparar alerta LOW_LIGHT y LED automático.
    light < min_light_percentage del perfil (típicamente 30-40%).
    """
    return {
        "moisture":    _jitter(62.0, 3.0),   # Humedad normal
        "temperature": _jitter(22.0, 0.5),
        "light":       _jitter(12.0, 2.0),   # Muy por debajo del umbral
    }


def scenario_critical(tick: int) -> dict:
    """
    Todo crítico — dispara DROUGHT + LOW_LIGHT simultáneamente.
    """
    return {
        "moisture":    _jitter(18.0, 2.0),
        "temperature": _jitter(24.5, 0.5),
        "light":       _jitter(8.0, 1.5),
    }


def scenario_demo(tick: int) -> dict:
    """
    Ciclo automático para demostración:
    - Ticks  0-11: Normal (60s)
    - Ticks 12-17: Sequía (30s)
    - Ticks 18-23: Recuperación gradual (30s)
    - Ticks 24-29: Poca luz (30s)
    - Ticks 30+:   Normal (repite)
    """
    phase = tick % 30
    if phase < 12:
        return scenario_normal(tick)
    elif phase < 18:
        return scenario_drought(tick)
    elif phase < 24:
        # Recuperación: humedad sube gradualmente
        progress = (phase - 18) / 6
        return {
            "moisture":    round(22.0 + progress * 45.0, 1),
            "temperature": _jitter(23.5, 0.5),
            "light":       _jitter(76.0, 3.0),
        }
    else:
        return scenario_low_light(tick)


def scenario_manual() -> dict:
    """Pide valores al usuario por consola."""
    print("\n  Ingresa los valores a publicar:")
    try:
        moisture    = float(input("  💧 Humedad del suelo  (0-100)%: ") or "60")
        temperature = float(input("  🌡️  Temperatura       (°C):      ") or "23")
        light       = float(input("  ☀️  Luz               (0-100)%:  ") or "70")
        return {
            "moisture":    round(moisture, 1),
            "temperature": round(temperature, 1),
            "light":       round(light, 1),
        }
    except ValueError:
        print("  ⚠️  Valor inválido, usando valores por defecto")
        return {"moisture": 60.0, "temperature": 23.0, "light": 70.0}


# ──────────────────────────────────────────────────────────────
# CONEXIÓN MQTT
# ──────────────────────────────────────────────────────────────

def create_mqtt_client():
    """Crea y configura el cliente MQTT con TLS para HiveMQ Cloud."""
    try:
        import paho.mqtt.client as mqtt
    except ImportError:
        print("\n  ❌  paho-mqtt no instalado.")
        print("      Ejecuta:  pip install paho-mqtt python-dotenv")
        sys.exit(1)

    client = mqtt.Client(
        mqtt.CallbackAPIVersion.VERSION2,
        client_id=f"usf-simulator-{random.randint(1000, 9999)}",
    )
    client.username_pw_set(MQTT_USER, MQTT_PASS)
    client.tls_set()  # TLS por defecto con certificados del sistema

    def on_connect(client, userdata, flags, reason_code, properties):
        if reason_code.is_failure:
            print(f"  ❌  Error de conexión: {reason_code}")
            sys.exit(1)
        else:
            print(f"  ✅  Conectado a HiveMQ Cloud")

    def on_disconnect(client, userdata, flags, reason_code, properties):
        if reason_code.is_failure:
            print(f"\n  ⚠️  Conexión perdida ({reason_code}). Reconectando...")

    def on_publish(client, userdata, mid, reason_code, properties):
        pass  # Confirmación silenciosa de publicación

    client.on_connect    = on_connect
    client.on_disconnect = on_disconnect
    client.on_publish    = on_publish

    return client


# ──────────────────────────────────────────────────────────────
# MENÚ Y DISPLAY
# ──────────────────────────────────────────────────────────────

SCENARIOS = {
    "1": ("🌱  Normal (valores saludables)",       scenario_normal),
    "2": ("🌵  Sequía (dispara alerta DROUGHT)",   scenario_drought),
    "3": ("🌑  Poca luz (dispara LOW_LIGHT)",       scenario_low_light),
    "4": ("🚨  Crítico (ambas alertas)",            scenario_critical),
    "5": ("📈  Demo fluido (ciclo automático)",     scenario_demo),
    "6": ("⚙️   Manual (ingresar valores)",          None),
}

SCENARIO_LABELS = {
    "1": "Normal",
    "2": "Sequía",
    "3": "Poca luz",
    "4": "Crítico",
    "5": "Demo",
    "6": "Manual",
}


def print_header():
    uuid_short = DEVICE_UUID[:8] + "..." if len(DEVICE_UUID) > 12 else DEVICE_UUID
    print("\n" + "═" * 62)
    print("║       Urban Smart Farming — Simulador ESP32 MQTT          ║")
    print("═" * 62)
    print(f"  Dispositivo : {DEVICE_UUID}")
    print(f"  Topic       : usf/telemetria/{uuid_short}")
    print(f"  Broker      : {MQTT_HOST}:{MQTT_PORT}")
    print(f"  Intervalo   : {INTERVAL_SECONDS}s")
    print("═" * 62)


def print_menu():
    print("\n  Selecciona el escenario a simular:\n")
    for key, (label, _) in SCENARIOS.items():
        print(f"    [{key}]  {label}")
    print("\n    [q]  Salir\n")


def format_bar(value: float, max_val: float = 100.0, width: int = 20) -> str:
    """Barra de progreso visual para los valores del sensor."""
    filled = int((value / max_val) * width)
    filled = max(0, min(width, filled))
    bar = "█" * filled + "░" * (width - filled)
    return f"[{bar}]"


def print_reading(payload: dict, tick: int, scenario_label: str):
    """Muestra los datos enviados de forma visual."""
    ts = datetime.now().strftime("%H:%M:%S")
    m = payload["moisture"]
    t = payload["temperature"]
    l = payload["light"]

    # Indicadores de estado
    m_icon = "💧" if m > 40 else "🌵"
    l_icon = "☀️ " if l > 35 else "🌑"
    t_icon = "🌡️ "

    print(f"\n  [{ts}] #{tick:>3}  ─── {scenario_label} ───")
    print(f"  {m_icon} Humedad     {format_bar(m)}  {m:>5.1f}%")
    print(f"  {t_icon} Temperatura {format_bar(t, 50.0)}  {t:>5.1f}°C")
    print(f"  {l_icon} Luz         {format_bar(l)}  {l:>5.1f}%")
    print(f"  📤  → {TOPIC}")


# ──────────────────────────────────────────────────────────────
# LOOP PRINCIPAL
# ──────────────────────────────────────────────────────────────

def run_loop(client, scenario_key: str):
    """Ejecuta el loop de publicación para el escenario seleccionado."""
    label = SCENARIO_LABELS[scenario_key]
    scenario_fn = SCENARIOS[scenario_key][1]
    is_manual = scenario_key == "6"

    print(f"\n  Iniciando simulación: {label}")
    print("  Presiona  Ctrl+C  para detener y volver al menú\n")

    tick = 0
    try:
        while True:
            if is_manual:
                payload = scenario_manual()
            else:
                payload = scenario_fn(tick)

            # Publicar al broker
            result = client.publish(TOPIC, json.dumps(payload), qos=1)
            result.wait_for_publish(timeout=5)

            print_reading(payload, tick, label)

            tick += 1
            if not is_manual:
                time.sleep(INTERVAL_SECONDS)

    except KeyboardInterrupt:
        print("\n\n  ⏹  Simulación detenida.")


# ──────────────────────────────────────────────────────────────
# MAIN
# ──────────────────────────────────────────────────────────────

def validate_config():
    """Valida que la configuración mínima esté completa."""
    errors = []

    if not MQTT_HOST:
        errors.append("MQTT_BROKER_HOST no encontrado en .env")
    if not MQTT_USER:
        errors.append("MQTT_USERNAME no encontrado en .env")
    if DEVICE_UUID == "PEGA-AQUI-EL-UUID-DEL-DEVICE":
        errors.append(
            "DEVICE_UUID no configurado.\n"
            "     Ve a Supabase → tabla Device → columna id\n"
            "     y pégalo en la variable DEVICE_UUID al inicio de este script."
        )

    if errors:
        print("\n  ❌  Configuración incompleta:")
        for e in errors:
            print(f"     • {e}")
        print()
        sys.exit(1)


def main():
    validate_config()
    print_header()

    # Conectar al broker
    print("\n  Conectando a HiveMQ Cloud...")
    client = create_mqtt_client()
    client.connect(MQTT_HOST, MQTT_PORT, keepalive=60)
    client.loop_start()
    time.sleep(1.5)  # Esperar callback on_connect

    # Bucle del menú
    try:
        while True:
            print_menu()
            choice = input("  Opción: ").strip().lower()

            if choice == "q":
                print("\n  👋  Hasta luego!\n")
                break
            elif choice in SCENARIOS:
                run_loop(client, choice)
            else:
                print("  ⚠️  Opción no válida")

    except KeyboardInterrupt:
        print("\n\n  👋  Saliendo...\n")

    finally:
        client.loop_stop()
        client.disconnect()


if __name__ == "__main__":
    main()
