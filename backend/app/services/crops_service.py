from uuid import UUID
from typing import Optional

from app.core.supabase import supabase_client
from app.models.crop import CropCreate

# Nota: Los comentarios y docstrings van en Español


async def list_crops(user: dict) -> list:
    """Devuelve todos los cultivos del usuario autenticado."""
    response = (
        supabase_client.table("Crop")
        .select("*")
        .eq("user_id", user["sub"])
        .order("created_at", desc=True)
        .execute()
    )
    return response.data or []


async def create_crop(data: CropCreate, user: dict) -> dict:
    """Crea un nuevo cultivo asociado al usuario autenticado."""
    row = {
        "user_id": user["sub"],
        "custom_name": data.custom_name,
        "profile_id": str(data.profile_id),
        "location": data.location,
    }
    if data.planting_date:
        row["planting_date"] = data.planting_date.isoformat()

    response = supabase_client.table("Crop").insert(row).execute()
    return response.data[0]


async def get_crop(crop_id: UUID, user: dict) -> Optional[dict]:
    """Devuelve un cultivo específico si pertenece al usuario autenticado."""
    response = (
        supabase_client.table("Crop")
        .select("*")
        .eq("id", str(crop_id))
        .eq("user_id", user["sub"])
        .maybe_single()
        .execute()
    )
    return response.data


async def delete_crop(crop_id: UUID, user: dict) -> None:
    """Elimina un cultivo del usuario autenticado."""
    supabase_client.table("Crop").delete().eq("id", str(crop_id)).eq("user_id", user["sub"]).execute()
