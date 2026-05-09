from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from uuid import UUID
from app.models.crop import CropCreate, CropResponse
from app.core.security import get_current_user
from app.services import crops_service

router = APIRouter(
    prefix="/api/v1/crops",
    tags=["Crops"]
)

@router.get(
    "",
    response_model=List[CropResponse],
    summary="Listar plantas del usuario",
    description="Obtiene todas las plantas asociadas al usuario autenticado."
)
async def list_crops(user: dict = Depends(get_current_user)):
    return await crops_service.list_crops(user)

@router.post(
    "",
    response_model=CropResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Crear una nueva planta",
    description="Crea una nueva planta asociada al perfil de cultivo."
)
async def create_crop(crop_data: CropCreate, user: dict = Depends(get_current_user)):
    return await crops_service.create_crop(crop_data, user)

@router.get(
    "/{crop_id}",
    response_model=CropResponse,
    summary="Obtener detalles de una planta",
    description="Devuelve los detalles de una planta específica del usuario autenticado."
)
async def get_crop(crop_id: UUID, user: dict = Depends(get_current_user)):
    crop = await crops_service.get_crop(crop_id, user)
    if not crop:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Crop not found")
    return crop
