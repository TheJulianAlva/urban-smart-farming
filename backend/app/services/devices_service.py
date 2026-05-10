from uuid import UUID
from typing import Optional

from app.core.supabase import supabase_client
from app.models.device import DeviceCreate

# Nota: Los comentarios y docstrings van en Español


def _crop_ids_for_user(user_sub: str) -> list[str]:
    """Devuelve la lista de IDs de cultivos que pertenecen al usuario."""
    response = (
        supabase_client.table("Crop")
        .select("id")
        .eq("user_id", user_sub)
        .execute()
    )
    return [row["id"] for row in (response.data or [])]


async def register_device(data: DeviceCreate, user: dict) -> dict:
    """
    Registra un nuevo dispositivo asociado a un cultivo del usuario.
    Lanza ValueError si el cultivo no pertenece al usuario o si la MAC ya existe.
    """
    # Verificar que el cultivo pertenece al usuario
    crop_check = (
        supabase_client.table("Crop")
        .select("id")
        .eq("id", str(data.crop_id))
        .eq("user_id", user["sub"])
        .maybe_single()
        .execute()
    )
    if not crop_check.data:
        raise ValueError("Cultivo no encontrado o no pertenece al usuario")

    # Verificar unicidad de MAC address
    mac_check = (
        supabase_client.table("Device")
        .select("id")
        .eq("mac_address", data.mac_address)
        .maybe_single()
        .execute()
    )
    if mac_check.data:
        raise ValueError("Ya existe un dispositivo con esta dirección MAC")

    response = (
        supabase_client.table("Device")
        .insert({"crop_id": str(data.crop_id), "mac_address": data.mac_address})
        .execute()
    )
    return response.data[0]


async def list_devices(user: dict) -> list:
    """Devuelve todos los dispositivos vinculados a los cultivos del usuario."""
    crop_ids = _crop_ids_for_user(user["sub"])
    if not crop_ids:
        return []
    response = (
        supabase_client.table("Device")
        .select("*")
        .in_("crop_id", crop_ids)
        .execute()
    )
    return response.data or []


async def delete_device(device_id: UUID, user: dict) -> None:
    """
    Elimina un dispositivo verificando que pertenezca al usuario.
    Lanza ValueError si el dispositivo no existe o no es del usuario.
    """
    crop_ids = _crop_ids_for_user(user["sub"])
    if not crop_ids:
        raise ValueError("Dispositivo no encontrado o no pertenece al usuario")

    device_check = (
        supabase_client.table("Device")
        .select("id")
        .eq("id", str(device_id))
        .in_("crop_id", crop_ids)
        .maybe_single()
        .execute()
    )
    if not device_check.data:
        raise ValueError("Dispositivo no encontrado o no pertenece al usuario")

    supabase_client.table("Device").delete().eq("id", str(device_id)).execute()
