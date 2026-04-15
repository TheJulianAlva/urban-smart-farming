"""
Middleware y dependencias de seguridad.

Implementa la validación del Bearer Token (JWT) emitido por Supabase Auth.

Supabase firma sus tokens con ES256 (clave asimétrica), por lo que la
validación se delega al propio cliente de Supabase en lugar de hacerla
manualmente con PyJWT + HS256.

Uso en cualquier endpoint que requiera autenticación:
    from app.core.security import get_current_user

    @router.get("/mi-recurso")
    async def mi_endpoint(user: dict = Depends(get_current_user)):
        ...
"""

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.core.supabase import supabase_client

# Esquema de seguridad: extrae el token del header "Authorization: Bearer <token>"
_bearer_scheme = HTTPBearer()


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(_bearer_scheme),
) -> dict:
    """
    Dependencia de FastAPI para validar el JWT de Supabase en un endpoint.

    Delega la verificación al cliente de Supabase, que maneja correctamente
    el algoritmo ES256 que Supabase usa para firmar sus tokens.

    Lanza HTTPException 401 si el token es inválido o ha expirado.
    """
    token = credentials.credentials

    try:
        user_response = supabase_client.auth.get_user(token)
        user = user_response.user
        if user is None:
            raise ValueError("Usuario no encontrado")
        return {"sub": user.id, "email": user.email}

    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token de autenticación inválido o expirado.",
        )
