from datetime import datetime
from uuid import UUID

from app.models.actuator import ActuatorCommand, ActuationResponse
from app.core.mqtt import mqtt_client
from app.core.supabase import supabase_client

# Nota: Los comentarios y docstrings van en Español


async def actuate_device(device_id: UUID, command: ActuatorCommand, user: dict) -> ActuationResponse:
    """
    Ejecuta un comando manual sobre un actuador.
    - Valida que el dispositivo pertenezca al usuario (via Device → Crop).
    - Publica el comando en MQTT.
    - Registra el ActuationEvent en Supabase.
    - Genera o resuelve una alerta asociada.
    """

    # 1. Verificar que el dispositivo pertenece al usuario (Device no tiene user_id;
    #    la propiedad se infiere por Device.crop_id → Crop.user_id)
    device_row = (
        supabase_client.table("Device")
        .select("id, mac_address, crop_id")
        .eq("id", str(device_id))
        .maybe_single()
        .execute()
    )

    if not device_row.data:
        raise ValueError("Dispositivo no encontrado")

    device = device_row.data
    crop_id = device.get("crop_id")

    # Verificar que el cultivo pertenece al usuario
    crop_check = (
        supabase_client.table("Crop")
        .select("id")
        .eq("id", crop_id)
        .eq("user_id", user["sub"])
        .maybe_single()
        .execute()
    )
    if not crop_check.data:
        raise ValueError("El dispositivo no pertenece al usuario autenticado")

    mac_address = device["mac_address"]

    # 2. Publicar comando en MQTT
    topic = f"usf/commands/{mac_address}"
    payload = {
        "actuator_type": command.actuator_type,
        "action": command.action,
        "duration_seconds": command.duration_seconds,
    }
    mqtt_client.publish(topic, str(payload))

    # 3. Registrar ActuationEvent en Supabase
    event_data = {
        "device_id": str(device_id),
        "crop_id": crop_id,
        "actuator_type": command.actuator_type,
        "action": command.action,
        "duration_seconds": command.duration_seconds,
        "triggered_by": "manual",
        "started_at": datetime.utcnow().isoformat(),
    }
    supabase_client.table("ActuationEvent").insert(event_data).execute()

    # 4. Gestionar alerta asociada
    if command.action == "on":
        alert_data = {
            "user_id": user["sub"],
            "device_id": str(device_id),
            "alert_type": "ACTUATOR_TRIGGERED",
            "message": f"Actuador '{command.actuator_type}' encendido manualmente",
            "is_resolved": False,
            "notification_sent": False,
            "created_at": datetime.utcnow().isoformat(),
        }
        supabase_client.table("Alert").insert(alert_data).execute()
    else:
        # Resolver alerta activa del mismo actuador
        active_alert = (
            supabase_client.table("Alert")
            .select("id")
            .eq("user_id", user["sub"])
            .eq("device_id", str(device_id))
            .eq("alert_type", "ACTUATOR_TRIGGERED")
            .eq("is_resolved", False)
            .order("created_at", desc=True)
            .limit(1)
            .maybe_single()
            .execute()
        )
        if active_alert.data:
            supabase_client.table("Alert").update({
                "is_resolved": True,
                "resolved_at": datetime.utcnow().isoformat(),
            }).eq("id", active_alert.data["id"]).execute()

    # 5. Respuesta al frontend
    return ActuationResponse(
        message="Comando de actuador ejecutado correctamente",
        actuator_type=command.actuator_type,
        action=command.action,
        started_at=datetime.utcnow().isoformat(),
    )
