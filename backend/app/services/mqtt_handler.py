import json
import logging
from app.core.mqtt import mqtt_client  # Usando el Singleton del core
from app.core.supabase import supabase_client  # Usando el Singleton del core
from app.core.config import settings

# Configuración de logs para monitorear el flujo en la terminal
logger = logging.getLogger(__name__)

def on_message(client, userdata, message):
    print(f"--- Mensaje recibido en el topico: {message.topic} ---")
    """Callback que se ejecuta cada vez que llega telemetría de una maceta"""
    try:
        # 1. Obtener el ID del dispositivo desde el tópico (usf/telemetria/AA:BB...)
        topic_parts = message.topic.split('/')
        device_id = topic_parts[-1]
        
        # 2. Parseo y Validación del JSON (Paso 3 del ticket)
        payload = json.loads(message.payload.decode())
        moisture = payload.get("moisture")
        temperature = payload.get("temperature")
        light = payload.get("light")

        if None in [moisture, temperature, light]:
            logger.warning(f"⚠️ Datos incompletos recibidos de {device_id}: {payload}")
            return

        # 3. Persistencia en Supabase (Paso 4 del ticket)
        supabase_client.table('SensorReading').insert({
            "device_id": device_id,           # Verifica que sea un UUID válido
            "avg_soil_moisture": moisture,    # Antes era "moisture"
            "avg_temperature": temperature,   # Antes era "temperature"
            "avg_light": light
        }).execute()
        logger.info(f"✅ Telemetría guardada para {device_id}")

        # 4. Evaluación de Umbrales y Alertas (Paso 5 del ticket - CU-11)
        process_alerts_and_actions(device_id, moisture, temperature, light)

    except json.JSONDecodeError:
        logger.error(f"❌ Error: El mensaje recibido no es un JSON válido en el tópico {message.topic}")
    except Exception as e:
        # Bloque de seguridad para evitar que el servidor crashee
        logger.error(f"❌ Error inesperado procesando telemetría: {str(e)}")

def process_alerts_and_actions(device_id, moisture, temp, light):
    """Lógica central para disparar alertas y actuadores automáticos"""
    # Consultar el perfil del cultivo asociado al dispositivo
    response = supabase_client.table("CropProfile").select("*").eq("device_id", device_id).maybe_single().execute()
    profile = response.data
    
    if not profile:
        logger.warning(f"❓ No se encontró un perfil para el dispositivo {device_id}")
        return

    # Mapeo de condiciones críticas
    conditions = [
        (moisture < profile['min_moisture'], "DROUGHT", "pump"),
        (light < profile['min_light_percentage'], "LOW_LIGHT", "light")
    ]

    for condition_met, alert_type, actuator in conditions:
        if condition_met:
            # A) Anti-spam: Verificar si ya hay una alerta activa
            active_alert = supabase_client.table("Alert").select("*").eq("device_id", device_id).eq("alert_type", alert_type).eq("is_resolved", False).execute()
            
            if not active_alert.data:
                # B) Insertar Alerta
                supabase_client.table("Alert").insert({
                    "device_id": device_id,
                    "alert_type": alert_type,
                    "message": f"Nivel crítico detectado: {alert_type}",
                    "is_resolved": False
                }).execute()

                # C) Publicar comando MQTT para el actuador
                command_payload = json.dumps({"actuator": actuator, "action": "on", "duration_seconds": 300})
                mqtt_client.publish(f"usf/commands/{device_id}", command_payload)
                
                # D) Registrar evento de actuación
                supabase_client.table("ActuationEvent").insert({
                    "device_id": device_id,
                    "triggered_by": "automatic",
                    "actuator_type": actuator
                }).execute()
                logger.info(f"🚀 Comando automático enviado: {actuator} para {device_id}")

# Actualiza la firma de la función con 'properties' al final
def on_connect(client, userdata, flags, rc, properties=None):
    if rc == 0:
        print("------------------------------------------")
        print("✅ CONEXIÓN EXITOSA: El backend ya habla con HiveMQ.")
        print("------------------------------------------")
        # Es mejor suscribirse aquí para asegurar que siempre escuche tras reconectar
        client.subscribe("usf/telemetria/#")
    else:
        print(f"❌ ERROR DE CONEXIÓN: Código {rc}. Revisa tus credenciales.")

def on_disconnect(client, userdata, flags, rc, properties=None):
    print(f"⚠️ Conexión MQTT perdida. Código: {rc}")

def start_mqtt_listener():
    print("------------------------------------------")
    print("📡 INICIANDO MOTOR MQTT (Puerto 8883)...")
    print("------------------------------------------")
    
    mqtt_client.on_connect = on_connect
    mqtt_client.on_disconnect = on_disconnect
    mqtt_client.on_message = on_message
    
    try:
        # Volvemos al puerto 8883 (Seguro para Python)
        mqtt_client.connect(settings.mqtt_broker_host, 8883)
        mqtt_client.loop_start() 
        print("🚀 Escucha iniciada en segundo plano.")
    except Exception as e:
        print(f"❌ Error crítico al conectar: {e}")
    logger.info("📡 Escuchando telemetría IoT en usf/telemetria/#")