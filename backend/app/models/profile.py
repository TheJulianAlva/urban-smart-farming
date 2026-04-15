from pydantic import BaseModel, Field
from uuid import UUID
from typing import Optional

class CropProfileCreate(BaseModel):
    """
    Modelo de entrada para crear un Perfil de cultivo.
    """
    name: str = Field(..., description="Nombre del perfil de cultivo")
    description: Optional[str] = Field(None, description="Descripción opcional del perfil")


class CropProfileResponse(BaseModel):
    """
    Modelo de salida que se devuelve al frontend después de crear o consultar un Perfil de cultivo.
    """
    id: UUID = Field(..., description="Identificador único del Perfil")
    user_id: str = Field(..., description="Identificador del usuario propietario (cifrado)")
    name: str = Field(..., description="Nombre del perfil de cultivo")
    description: Optional[str] = Field(None, description="Descripción opcional del perfil")
    created_at: str = Field(..., description="Fecha de creación en formato ISO8601")
    updated_at: Optional[str] = Field(None, description="Fecha de última actualización en formato ISO8601")
