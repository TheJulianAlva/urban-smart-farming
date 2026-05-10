from pydantic import BaseModel, Field
from uuid import UUID
from typing import Optional
from datetime import date, datetime

# Nota: Los comentarios y docstrings van en Español


class CropCreate(BaseModel):
    """Modelo de entrada para crear un Cultivo desde el celular."""
    custom_name: str = Field(..., description="Nombre personalizado asignado por el usuario")
    profile_id: UUID = Field(..., description="UUID del perfil de cultivo asociado")
    location: str = Field(default="", description="Ubicación textual del cultivo")
    planting_date: Optional[date] = Field(None, description="Fecha de siembra")


class CropResponse(BaseModel):
    """Modelo de salida que se devuelve al frontend al crear o consultar un Cultivo."""
    id: UUID = Field(..., description="Identificador único del cultivo")
    user_id: str = Field(..., description="UUID del usuario propietario")
    custom_name: str = Field(..., description="Nombre personalizado del cultivo")
    profile_id: Optional[UUID] = Field(None, description="UUID del perfil de cultivo asociado")
    health_status: Optional[str] = Field(None, description="Estado de salud: healthy, warning, critical")
    location: str = Field(default="", description="Ubicación textual del cultivo")
    planting_date: Optional[date] = Field(None, description="Fecha de siembra")
    icon_storage_url: Optional[str] = Field(None, description="URL de imagen en Supabase Storage")
    created_at: Optional[datetime] = Field(None, description="Fecha de creación ISO8601")
    updated_at: Optional[datetime] = Field(None, description="Fecha de última actualización ISO8601")
