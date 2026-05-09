from pydantic import BaseModel, Field
from uuid import UUID
from typing import Optional
from datetime import datetime

# 🚨 Nota: Los comentarios y docstrings van en Español

class AlertResponse(BaseModel):
    """
    Modelo de salida para representar una Alerta en el sistema.
    """
    id: UUID = Field(..., description="Identificador único de la alerta")
    user_id: str = Field(..., description="Identificador del usuario propietario (cifrado)")
    device_id: Optional[UUID] = Field(None, description="Identificador del dispositivo asociado")
    type: str = Field(..., description="Tipo de alerta (ej. ACTUATOR_TRIGGERED, SENSOR_THRESHOLD)")
    is_resolved: bool = Field(..., description="Indica si la alerta ya fue resuelta")
    notification_sent: bool = Field(..., description="Indica si se envió notificación al usuario")
    created_at: datetime = Field(..., description="Fecha de creación de la alerta en formato ISO8601")
    resolved_at: Optional[datetime] = Field(None, description="Fecha en que la alerta fue resuelta")

class AlertResolveRequest(BaseModel):
    """
    Modelo de entrada para resolver una alerta.
    """
    is_resolved: bool = Field(True, description="Campo para marcar la alerta como resuelta")
    resolved_at: datetime = Field(..., description="Fecha/hora en que se resolvió la alerta")
