"""
Punto de entrada principal de la API.

Configura la instancia de FastAPI, registra los middlewares globales
(CORS) y todos los routers del sistema.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.services.mqtt_handler import start_mqtt_listener

# ---------------------------------------------------------------------------
# Instancia de la Aplicación
# ---------------------------------------------------------------------------

app = FastAPI(
    title="Urban Smart Farming API",
    description="Backend de la plataforma IoT para monitoreo y automatización de cultivos urbanos.",
    version="0.1.0",
)

@app.on_event("startup")
def startup_event():
    """Inicia la escucha de mensajes IoT."""
    start_mqtt_listener()

# ---------------------------------------------------------------------------
# Middleware de CORS
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
#
# Nota: 'actuators' y 'devices' comparten el prefix /api/v1/devices.
# Los paths no colisionan: devices usa /register y /{id},
# actuators usa /{id}/actuate.
# ---------------------------------------------------------------------------

from app.routers import users, vision, crops, devices, alerts, history, actuators

app.include_router(vision.router,    prefix="/api/v1")
app.include_router(users.router,     prefix="/api/v1")
app.include_router(crops.router)
app.include_router(devices.router)
app.include_router(alerts.router)
app.include_router(history.router)
app.include_router(actuators.router)

# ---------------------------------------------------------------------------
# Endpoints Base
# ---------------------------------------------------------------------------

@app.get("/", tags=["Health"])
async def health_check():
    """Prueba de vida del servidor."""
    return {
        "status": "online",
        "message": "Urban Smart Farming API is running!",
        "version": "0.1.0",
    }
