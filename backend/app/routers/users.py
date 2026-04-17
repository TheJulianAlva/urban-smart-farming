"""
Router de Usuarios — Perfil de la cuenta autenticada.

Responsabilidades:
1. Exponer el perfil del usuario autenticado desde public.User.
2. Actuar como fallback: si el trigger de Supabase no creó el row
   (e.g. usuario previo a la migración), lo crea en el momento.
"""

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel

from app.core.security import get_current_user
from app.core.supabase import supabase_client

router = APIRouter(prefix="/users", tags=["Users"])


class UserProfile(BaseModel):
    id: str
    full_name: str
    email: str


@router.get("/me", response_model=UserProfile)
def get_my_profile(current_user: dict = Depends(get_current_user)) -> UserProfile:
    """
    Devuelve el perfil del usuario autenticado desde public.User.

    Si la fila no existe (caso de usuarios registrados antes del trigger),
    la crea automáticamente usando los datos del token JWT.
    """
    auth_id = current_user["sub"]

    response = (
        supabase_client.table("User")
        .select("id, full_name, email")
        .eq("id", auth_id)
        .maybe_single()
        .execute()
    )

    if response.data:
        return UserProfile(**response.data)

    # Fallback: perfil faltante (usuario pre-trigger). Crear ahora.
    email = current_user.get("email", "")
    insert_response = (
        supabase_client.table("User")
        .insert({
            "id": auth_id,
            "full_name": email.split("@")[0],
            "email": email,
        })
        .execute()
    )

    if not insert_response.data:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="No se pudo crear el perfil del usuario.",
        )

    return UserProfile(**insert_response.data[0])
