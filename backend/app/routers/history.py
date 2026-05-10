from fastapi import APIRouter, Depends, Query, HTTPException, status
from typing import List
from uuid import UUID

from app.core.security import get_current_user
from app.services import history_service
from app.models.history import SensorReadingResponse, LatestSensorReadingResponse

router = APIRouter(
    prefix="/api/v1/sensor-readings",
    tags=["History"]
)


@router.get(
    "/latest",
    response_model=LatestSensorReadingResponse,
    summary="Última lectura de sensores",
    description="Devuelve la lectura más reciente del cultivo. Usada por el Dashboard en tiempo real."
)
async def get_latest_reading(
    crop_id: UUID = Query(..., description="UUID del cultivo"),
    user: dict = Depends(get_current_user)
):
    reading = await history_service.get_latest_reading(crop_id, user)
    if reading is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No se encontró lectura. El cultivo puede no tener dispositivo registrado."
        )
    return reading


@router.get(
    "",
    response_model=List[SensorReadingResponse],
    summary="Historial de lecturas de sensores",
    description="Devuelve lecturas de sensores filtradas por cultivo y rango de tiempo (day, week, month)."
)
async def get_sensor_readings(
    crop_id: UUID = Query(..., description="UUID del cultivo"),
    range: str = Query(..., pattern="^(day|week|month)$", description="Rango de tiempo"),
    user: dict = Depends(get_current_user)
):
    readings = await history_service.get_sensor_readings(crop_id, range, user)
    if not readings:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No se encontraron lecturas")
    return readings
