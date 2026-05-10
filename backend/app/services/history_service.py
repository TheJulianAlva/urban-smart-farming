from uuid import UUID
from typing import Optional
from datetime import datetime, timedelta

from app.core.supabase import supabase_client

# Nota: Los comentarios y docstrings van en Español

_RANGE_DELTA = {
    "day": timedelta(days=1),
    "week": timedelta(weeks=1),
    "month": timedelta(days=30),
}


def _get_device_id_for_crop(crop_id: str, user_sub: str) -> Optional[str]:
    """
    Devuelve el device_id del dispositivo asociado a un cultivo del usuario.
    Retorna None si el cultivo no existe, no es del usuario, o no tiene dispositivo.
    """
    crop_check = (
        supabase_client.table("Crop")
        .select("id")
        .eq("id", crop_id)
        .eq("user_id", user_sub)
        .maybe_single()
        .execute()
    )
    if not crop_check.data:
        return None

    device = (
        supabase_client.table("Device")
        .select("id")
        .eq("crop_id", crop_id)
        .maybe_single()
        .execute()
    )
    return device.data["id"] if device.data else None


async def get_sensor_readings(crop_id: UUID, range: str, user: dict) -> list:
    """
    Devuelve lecturas de sensores del cultivo en el rango de tiempo indicado.
    range: 'day' | 'week' | 'month'
    """
    device_id = _get_device_id_for_crop(str(crop_id), user["sub"])
    if not device_id:
        return []

    start = datetime.utcnow() - _RANGE_DELTA.get(range, timedelta(days=1))

    response = (
        supabase_client.table("SensorReading")
        .select("*")
        .eq("device_id", device_id)
        .gte("recorded_at", start.isoformat())
        .order("recorded_at", desc=False)
        .execute()
    )
    return response.data or []


async def get_latest_reading(crop_id: UUID, user: dict) -> Optional[dict]:
    """
    Devuelve la lectura de sensores más reciente del cultivo.
    Usado por el DashboardScreen para mostrar datos en tiempo real.
    Retorna None si el cultivo no tiene dispositivo registrado.
    """
    device_id = _get_device_id_for_crop(str(crop_id), user["sub"])
    if not device_id:
        return None

    response = (
        supabase_client.table("SensorReading")
        .select("avg_temperature, avg_soil_moisture, avg_light, recorded_at")
        .eq("device_id", device_id)
        .order("recorded_at", desc=True)
        .limit(1)
        .maybe_single()
        .execute()
    )
    return response.data
