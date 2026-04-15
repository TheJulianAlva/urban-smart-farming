from fastapi import APIRouter, Depends, HTTPException, status
from uuid import UUID
from app.core.security import get_current_user
from app.services import actuators_service
from app.models.actuator import ActuatorCommand, ActuationResponse

router = APIRouter(
    prefix="/api/v1/devices",
    tags=["Actuators"]
)

@router.post(
    "/{device_id}/actuate",
    response_model=ActuationResponse,
    summary="Control manual de actuadores",
    description="Permite al usuario encender/apagar actuadores (bomba o luz) de un dispositivo."
)
async def actuate_device(
    device_id: UUID,
    command: ActuatorCommand,
    user: dict = Depends(get_current_user)
):
    try:
        return await actuators_service.actuate_device(device_id, command, user)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
