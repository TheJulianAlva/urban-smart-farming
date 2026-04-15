from pydantic import BaseModel, Field
from typing import Literal, Optional

class ActuatorCommand(BaseModel):
    actuator_type: Literal["pump", "light"] = Field(..., description="Tipo de actuador")
    action: Literal["on", "off"] = Field(..., description="Acción a ejecutar")
    duration_seconds: Optional[int] = Field(None, description="Duración en segundos")

class ActuationResponse(BaseModel):
    message: str = Field(..., description="Mensaje de confirmación")
    actuator_type: str = Field(..., description="Tipo de actuador")
    action: str = Field(..., description="Acción ejecutada")
    started_at: str = Field(..., description="Fecha/hora de inicio en ISO8601")
