from pydantic import BaseModel, Field
from uuid import UUID
from typing import Optional
from datetime import datetime

# Nota: Los comentarios y docstrings van en Español

class SensorReadingResponse(BaseModel):
    """
    Modelo de salida para representar una lectura de sensor en el historial.
    """
    id: UUID = Field(..., description="Identificador único de la lectura")
    user_id: str = Field(..., description="Identificador del usuario propietario (cifrado)")
    crop_id: UUID = Field(..., description="UUID del cultivo asociado a la lectura")
    sensor_type: str = Field(..., description="Tipo de sensor (ej. temperatura, humedad, luz)")
    value: float = Field(..., description="Valor numérico registrado por el sensor")
    unit: str = Field(..., description="Unidad de medida del valor (ej. °C, %, lux)")
    recorded_at: datetime = Field(..., description="Fecha/hora en que se registró la lectura en formato ISO8601")
    range_bucket: Optional[str] = Field(None, description="Etiqueta de agrupación por rango (ej. day, week, month)")
