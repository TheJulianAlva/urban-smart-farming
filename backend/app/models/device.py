from pydantic import BaseModel, Field
from uuid import UUID
from typing import Optional
from datetime import datetime

# Nota: Los comentarios y docstrings van en Español


class DeviceCreate(BaseModel):
    """Modelo de entrada para registrar un nuevo dispositivo físico (ESP32)."""
    mac_address: str = Field(..., description="Dirección MAC única del dispositivo")
    crop_id: UUID = Field(..., description="UUID del cultivo al que se asocia el dispositivo")


class DeviceResponse(BaseModel):
    """Modelo de salida que representa un dispositivo registrado en el sistema."""
    id: UUID = Field(..., description="Identificador único del dispositivo")
    crop_id: Optional[UUID] = Field(None, description="UUID del cultivo asociado")
    mac_address: str = Field(..., description="Dirección MAC única del dispositivo")
    last_heartbeat: Optional[datetime] = Field(None, description="Última conexión MQTT registrada")
