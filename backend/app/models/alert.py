from pydantic import BaseModel, Field
from uuid import UUID
from typing import Optional
from datetime import datetime

# Nota: Los comentarios y docstrings van en Español


class AlertResponse(BaseModel):
    """Modelo de salida para representar una Alerta en el sistema."""
    id: UUID = Field(..., description="Identificador único de la alerta")
    user_id: str = Field(..., description="UUID del usuario propietario")
    device_id: Optional[UUID] = Field(None, description="UUID del dispositivo asociado")
    alert_type: Optional[str] = Field(None, description="Tipo de alerta (ej. SENSOR_THRESHOLD, ACTUATOR_TRIGGERED)")
    message: Optional[str] = Field(None, description="Mensaje descriptivo de la alerta")
    is_resolved: bool = Field(..., description="Indica si la alerta fue resuelta")
    notification_sent: bool = Field(default=False, description="Indica si se envió notificación al usuario")
    created_at: datetime = Field(..., description="Fecha de creación en formato ISO8601")
    resolved_at: Optional[datetime] = Field(None, description="Fecha en que se resolvió la alerta")
