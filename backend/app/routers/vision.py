"""
Router de Visión IA — Fachada HTTP.

Responsabilidades:
1. Recibir la imagen y el crop_id del cliente (Flutter/Swagger).
2. Delegar el análisis al GeminiService.
3. Persistir el resultado en la tabla VisionAnalysis de Supabase.
4. Devolver el registro creado al cliente.
"""

from datetime import datetime, timezone
from typing import Any

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status

from app.core.security import get_current_user
from app.core.supabase import supabase_client
from app.services.gemini_service import analyze_plant_image

router = APIRouter(prefix="/vision", tags=["Vision AI"])


@router.post("/analyze", status_code=status.HTTP_201_CREATED)
async def analyze_crop_image(
    crop_id: str | None = Form(default=None, description="ID del cultivo a diagnosticar (opcional)."),
    image: UploadFile = File(..., description="Foto de la planta (JPEG, PNG, etc.)."),
    current_user: dict = Depends(get_current_user),
) -> Any:
    """
    Analiza una imagen de planta con Gemini Vision AI y persiste el diagnóstico.

    - **crop_id**: ID del cultivo asociado en la base de datos.
    - **image**: Archivo de imagen enviado como multipart/form-data.

    Devuelve el registro completo de `VisionAnalysis` recién creado.
    """
    # ------------------------------------------------------------------
    # 1. Leer los bytes de la imagen
    # ------------------------------------------------------------------
    image_bytes = await image.read()
    mime_type = image.content_type or "image/jpeg"
    if mime_type == "application/octet-stream":
        import mimetypes
        guessed, _ = mimetypes.guess_type(image.filename or "")
        mime_type = guessed or "image/jpeg"

    # ------------------------------------------------------------------
    # 2. Obtener el diagnóstico de Gemini (delega al servicio)
    #    Si falla, el servicio lanza HTTPException 503 o 502 directamente.
    # ------------------------------------------------------------------
    diagnosis_result = await analyze_plant_image(
        image_bytes=image_bytes,
        mime_type=mime_type,
    )

    # ------------------------------------------------------------------
    # 3. Persistir en la tabla VisionAnalysis de Supabase
    # ------------------------------------------------------------------
    record = {
        "diagnosis": diagnosis_result["diagnosis"],
        "suggested_treatment": diagnosis_result["suggested_treatment"],
        "confidence_percentage": diagnosis_result["confidence_percentage"],
        "analysis_date": datetime.now(timezone.utc).isoformat(),
    }
    if crop_id:
        record["crop_id"] = crop_id

    response = supabase_client.table("VisionAnalysis").insert(record).execute()

    if not response.data:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="El diagnóstico se obtuvo correctamente pero no pudo guardarse en la base de datos.",
        )

    # ------------------------------------------------------------------
    # 4. Devolver el registro recién creado al cliente Flutter
    # ------------------------------------------------------------------
    return response.data[0]
