"""
Punto de entrada principal de API.

Configura la instancia de FastAPI, registra los middlewares globales
(CORS) y define los endpoints base del sistema.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# ---------------------------------------------------------------------------
# Instancia de la Aplicación
# ---------------------------------------------------------------------------

app = FastAPI(
    title="Urban Smart Farming API",
    description="Backend de la plataforma IoT para monitoreo y automatización de cultivos urbanos.",
    version="0.1.0",
)

# ---------------------------------------------------------------------------
# Middleware de CORS
#
# Permite que la aplicación Flutter (móvil o web) y herramientas de desarrollo
# (Postman, Swagger) puedan comunicarse con esta API sin ser bloqueadas por
# las políticas de seguridad del navegador.
#
# ---------------------------------------------------------------------------

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------------
# Registro de Routers
# ---------------------------------------------------------------------------

from app.routers import vision

app.include_router(vision.router, prefix="/api/v1")


# ---------------------------------------------------------------------------
# Endpoints Base
# ---------------------------------------------------------------------------


@app.get("/", tags=["Health"])
async def health_check():
    """
    Prueba de vida del servidor.

    Devuelve un mensaje confirmando que la API está en línea.
    Útil para que herramientas de monitoreo validen la disponibilidad del servicio.
    """
    return {
        "status": "online",
        "message": "Urban Smart Farming API is running!",
        "version": "0.1.0",
    }
