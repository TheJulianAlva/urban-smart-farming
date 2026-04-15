from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from uuid import UUID
from app.core.security import get_current_user
from app.services import devices_service
from app.models.device import DeviceCreate, DeviceResponse

router = APIRouter(
    prefix="/api/v1/devices",
    tags=["Devices"]
)

@router.post(
    "/register",
    response_model=DeviceResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Registrar un dispositivo",
    description="Asocia un dispositivo físico (maceta/ESP32) al usuario autenticado."
)
async def register_device(device_data: DeviceCreate, user: dict = Depends(get_current_user)):
    try:
        return await devices_service.register_device(device_data, user)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(e))

@router.get(
    "",
    response_model=List[DeviceResponse],
    summary="Listar dispositivos del usuario",
    description="Obtiene todos los dispositivos asociados al usuario autenticado."
)
async def list_devices(user: dict = Depends(get_current_user)):
    return await devices_service.list_devices(user)

@router.delete(
    "/{device_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Eliminar un dispositivo",
    description="Desvincula un dispositivo del usuario autenticado."
)
async def delete_device(device_id: UUID, user: dict = Depends(get_current_user)):
    await devices_service.delete_device(device_id, user)
    return None
