from fastapi import APIRouter, Depends, Query, HTTPException, status
from typing import List
from uuid import UUID
from app.core.security import get_current_user
from app.services import history_service
from app.models.history import SensorReadingResponse

router = APIRouter(
    prefix="/api/v1/sensor-readings",
    tags=["History"]
)

@router.get(
    "",
    response_model=List[SensorReadingResponse],
    summary="Obtener lecturas de sensores",
    description="Devuelve lecturas de sensores filtradas por cultivo y rango de tiempo (día, semana, mes)."
)
async def get_sensor_readings(
    crop_id: UUID = Query(..., description="UUID del cultivo"),
    range: str = Query(..., regex="^(day|week|month)$", description="Rango de tiempo"),
    user: dict = Depends(get_current_user)
):
    readings = await history_service.get_sensor_readings(crop_id, range, user)
    if not readings:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No readings found")
    return readings
