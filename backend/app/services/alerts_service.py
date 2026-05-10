from uuid import UUID
from typing import Optional
from datetime import datetime

from app.core.supabase import supabase_client

# Nota: Los comentarios y docstrings van en Español


async def list_alerts(user: dict) -> list:
    """Devuelve todas las alertas activas (no resueltas) del usuario, más recientes primero."""
    response = (
        supabase_client.table("Alert")
        .select("*")
        .eq("user_id", user["sub"])
        .eq("is_resolved", False)
        .order("created_at", desc=True)
        .execute()
    )
    return response.data or []


async def resolve_alert(alert_id: UUID, user: dict, resolved_at: datetime) -> Optional[dict]:
    """
    Marca una alerta como resuelta.
    Devuelve la alerta actualizada, o None si no existe o no pertenece al usuario.
    """
    response = (
        supabase_client.table("Alert")
        .update({
            "is_resolved": True,
            "resolved_at": resolved_at.isoformat(),
        })
        .eq("id", str(alert_id))
        .eq("user_id", user["sub"])
        .execute()
    )
    return response.data[0] if response.data else None
