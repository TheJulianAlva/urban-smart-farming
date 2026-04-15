from pydantic import BaseModel, Field
from uuid import UUID
from typing import Optional
from datetime import datetime

# 🚨 Nota: Los comentarios y docstrings van en Español

class DeviceCreate(BaseModel):
    """
    Modelo de entrada para registrar un nuevo dispositivo físico (maceta/ESP32).
    """
    mac_address: str = Field(..., description="Dirección MAC única del dispositivo")
    crop_id: UUID = Field(..., description="UUID del cultivo asociado al dispositivo")


class DeviceResponse(BaseModel):
    """
    Modelo de salida que representa un dispositivo registrado en el sistema.
    """
    id: UUID = Field(..., description="Identificador único del dispositivo")
    user_id: str = Field(..., description="Identificador del usuario propietario (cifrado)")
    mac_address: str = Field(..., description="Dirección MAC única del dispositivo")
    crop_id: UUID = Field(..., description="UUID del cultivo asociado")
    created_at: datetime = Field(..., description="Fecha de creación en formato ISO8601")
    updated_at: Optional[datetime] = Field(None, description="Fecha de última actualización en formato ISO8601")
