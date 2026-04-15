from datetime import datetime
from uuid import UUID
from app.models.actuator import ActuatorCommand, ActuationResponse
from app.core.mqtt import mqtt_client
from app.core.supabase import supabase_client

# 🚨 Nota: Los comentarios y docstrings van en Español

async def actuate_device(device_id: UUID, command: ActuatorCommand, user: dict) -> ActuationResponse:
    """
    Servicio para ejecutar un comando manual sobre un actuador.
    - Publica el comando en MQTT.
    - Registra el evento en Supabase.
    - Genera o resuelve una alerta asociada.
    """

    # 1️⃣ Obtener el dispositivo para validar que pertenece al usuario
    device = await supabase_client.table("Device") \
        .select("id, mac_address") \
        .eq("id", str(device_id)) \
        .eq("user_id", user["sub"]) \
        .single()

    if not device:
        raise ValueError("Device not found or not owned by user")

    mac_address = device["mac_address"]

    # 2️⃣ Publicar comando en MQTT
    topic = f"usf/commands/{mac_address}"
    payload = {
        "actuator_type": command.actuator_type,
        "action": command.action,
        "duration_seconds": command.duration_seconds
    }
    mqtt_client.publish(topic, str(payload))

    # 3️⃣ Registrar evento en Supabase
    event_data = {
        "device_id": str(device_id),
        "user_id": user["sub"],
        "actuator_type": command.actuator_type,
        "action": command.action,
        "duration_seconds": command.duration_seconds,
        "triggered_by": "manual",
        "started_at": datetime.utcnow().isoformat()
    }
    await supabase_client.table("ActuationEvent").insert(event_data)

    # 4️⃣ Generar o resolver alerta
    if command.action == "on":
        alert_data = {
            "user_id": user["sub"],
            "device_id": str(device_id),
            "type": "ACTUATOR_TRIGGERED",
            "is_resolved": False,
            "notification_sent": False,
            "created_at": datetime.utcnow().isoformat()
        }
        await supabase_client.table("Alert").insert(alert_data)
    else:
        # Buscar alerta activa y marcarla como resuelta
        active_alert = await supabase_client.table("Alert") \
            .select("id") \
            .eq("user_id", user["sub"]) \
            .eq("device_id", str(device_id)) \
            .eq("type", "ACTUATOR_TRIGGERED") \
            .eq("is_resolved", False) \
            .order("created_at", desc=True) \
            .limit(1) \
            .single()

        if active_alert:
            await supabase_client.table("Alert") \
                .update({"is_resolved": True, "resolved_at": datetime.utcnow().isoformat()}) \
                .eq("id", active_alert["id"])

    # 5️⃣ Respuesta al frontend
    return ActuationResponse(
        message="Actuator command executed successfully",
        actuator_type=command.actuator_type,
        action=command.action,
        started_at=datetime.utcnow().isoformat()
    )
