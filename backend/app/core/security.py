"""
Middleware y dependencias de seguridad.

Implementa la validación del Bearer Token (JWT) emitido por Supabase Auth.

El JWT se verifica en cada petición a los endpoints protegidos ANTES de
ejecutar cualquier lógica de negocio. Si el token es inválido, expirado o
ausente, FastAPI devuelve automáticamente un error HTTP 401.

Uso en cualquier endpoint que requiera autenticación:
    from app.core.security import get_current_user

    @router.get("/mi-recurso")
    async def mi_endpoint(user: dict = Depends(get_current_user)):
        ...
"""

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.core.config import settings

# Esquema de seguridad: extrae el token del header "Authorization: Bearer <token>"
_bearer_scheme = HTTPBearer()


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(_bearer_scheme),
) -> dict:
    """
    Dependencia de FastAPI para validar el JWT de Supabase en un endpoint.

    Extrae y verifica la firma del token. Si es válido, devuelve el payload
    (información del usuario como su ID) para que el endpoint lo pueda usar.

    Lanza HTTPException 401 si:
    - El token está ausente.
    - La firma es inválida o fue manipulada.
    - El token ha expirado.
    """
    token = credentials.credentials

    try:
        payload = jwt.decode(
            token,
            settings.supabase_key,
            algorithms=["HS256"],
            options={"verify_aud": False},
        )
        return payload

    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="El token de sesión ha expirado. Inicia sesión nuevamente.",
        )
    except jwt.InvalidTokenError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token de autenticación inválido.",
        )
