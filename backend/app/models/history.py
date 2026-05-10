from pydantic import BaseModel, Field
from uuid import UUID
from typing import Optional
from datetime import datetime

# Nota: Los comentarios y docstrings van en Español


class SensorReadingResponse(BaseModel):
    """Modelo de salida para una lectura de sensores en el historial."""
    id: int = Field(..., description="Identificador incremental de la lectura")
    device_id: UUID = Field(..., description="UUID del dispositivo que generó la lectura")
    avg_soil_moisture: Optional[float] = Field(None, description="Humedad del suelo promediada (%)")
    avg_temperature: Optional[float] = Field(None, description="Temperatura ambiente (°C)")
    avg_light: Optional[float] = Field(None, description="Intensidad de luz (lux)")
    recorded_at: Optional[datetime] = Field(None, description="Fecha/hora del registro ISO8601")


class LatestSensorReadingResponse(BaseModel):
    """Modelo de salida para la lectura más reciente de un cultivo (Dashboard)."""
    avg_temperature: Optional[float] = Field(None, description="Temperatura ambiente (°C)")
    avg_soil_moisture: Optional[float] = Field(None, description="Humedad del suelo (%)")
    avg_light: Optional[float] = Field(None, description="Intensidad de luz (lux)")
    recorded_at: Optional[datetime] = Field(None, description="Fecha/hora del registro ISO8601")
