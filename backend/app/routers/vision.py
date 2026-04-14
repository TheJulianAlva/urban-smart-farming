from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException, status
from typing import Any
from app.core.security import get_current_user
from app.core.supabase import supabase_client

router = APIRouter(prefix="/vision", tags=["Vision AI"])

@router.post("/analyze", status_code=status.HTTP_201_CREATED)
async def analyze_crop_image(
    crop_id: str = Form(...),
    image: UploadFile = File(...),
    current_user: dict = Depends(get_current_user)
) -> Any:
    """
    Recibe una imagen de una planta y un ID de cultivo para su análisis con IA.
    
    - **crop_id**: ID del cultivo asociado.
    - **image**: Archivo de imagen (multipart/form-data).
    """
    # TODO: Implementar llamada al GeminiService (Paso 2)
    # TODO: Implementar persistencia en VisionAnalysis (Paso 3)
    
    return {
        "message": "Endpoint en construcción",
        "crop_id": crop_id,
        "filename": image.filename
    }
