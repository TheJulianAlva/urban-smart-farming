from pydantic import BaseModel, Field
from uuid import UUID
from typing import Optional

# 🚨 Nota: Los comentarios y docstrings van en Español

class CropCreate(BaseModel):
    """
    Modelo de entrada para crear una Planta desde el celular.
    """
    custom_name: str = Field(..., description="Nombre personalizado asignado por el usuario")
    profile_id: UUID = Field(..., description="UUID del perfil de cultivo asociado")


class CropResponse(BaseModel):
    """
    Modelo de salida que se devuelve al frontend después de crear o consultar una Planta.
    """
    id: UUID = Field(..., description="Identificador único de la Planta")
    user_id: str = Field(..., description="Identificador del usuario propietario (cifrado)")
    custom_name: str = Field(..., description="Nombre personalizado de la Planta")
    profile_id: UUID = Field(..., description="UUID del perfil de cultivo asociado")
    status: str = Field(..., description="Estado actual de la Planta (ej. activo, inactivo)")
    created_at: str = Field(..., description="Fecha de creación en formato ISO8601")
    updated_at: Optional[str] = Field(None, description="Fecha de última actualización en formato ISO8601")
