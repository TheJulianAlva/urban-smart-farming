from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from uuid import UUID
from datetime import datetime
from app.core.security import get_current_user
from app.services import alerts_service
from app.models.alert import AlertResponse

router = APIRouter(
    prefix="/api/v1/alerts",
    tags=["Alerts"]
)

@router.get(
    "",
    response_model=List[AlertResponse],
    summary="Listar alertas activas",
    description="Devuelve todas las alertas activas del usuario autenticado, ordenadas por fecha descendente."
)
async def list_alerts(user: dict = Depends(get_current_user)):
    return await alerts_service.list_alerts(user)

@router.patch(
    "/{alert_id}/resolve",
    response_model=AlertResponse,
    summary="Resolver una alerta",
    description="Marca una alerta específica como resuelta."
)
async def resolve_alert(alert_id: UUID, user: dict = Depends(get_current_user)):
    alert = await alerts_service.resolve_alert(alert_id, user, resolved_at=datetime.utcnow())
    if not alert:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Alert not found")
    return alert
