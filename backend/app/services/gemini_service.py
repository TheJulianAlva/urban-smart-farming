"""
Servicio de Diagnóstico con Gemini Vision AI — Patrón Facade.

Este módulo actúa como fachada entre el Router y la API de Google Generative AI.
Toda la lógica de comunicación con Gemini está encapsulada aquí, lo que permite
que el router se mantenga limpio y desacoplado de los detalles de implementación.

Uso:
    from app.services.gemini_service import analyze_plant_image

    result = await analyze_plant_image(image_bytes=bytes_de_la_imagen)
    # result = {"diagnosis": ..., "suggested_treatment": ..., "confidence_percentage": ...}
"""

import json
import logging

import google.generativeai as genai
from fastapi import HTTPException, status

from app.core.config import settings

# ---------------------------------------------------------------------------
# Configuración del Logger
# ---------------------------------------------------------------------------
# Usamos el logger estándar de Python para registrar errores inesperados
# sin detener el servidor.
logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Configuración del Cliente Gemini
# ---------------------------------------------------------------------------
# Se configura una única vez al cargar el módulo, usando la API Key del .env.
genai.configure(api_key=settings.gemini_api_key)

# Usamos gemini-1.5-flash por su velocidad y capacidad multimodal (texto + imagen).
_model = genai.GenerativeModel("gemini-2.5-flash")

# ---------------------------------------------------------------------------
# Prompt Estricto
# ---------------------------------------------------------------------------
# La instrucción al modelo es explícita: responder SOLO con el JSON indicado,
# sin texto adicional, sin markdown, sin explicaciones.
_DIAGNOSIS_PROMPT = """
Eres un experto agrónomo y botanista. Analiza la imagen de la planta que se te proporciona.

Responde EXCLUSIVAMENTE con un objeto JSON válido. No incluyas texto adicional,
no uses bloques de código markdown, no incluyas explicaciones.

El JSON debe seguir esta estructura exacta:
{
  "diagnosis": "Nombre del problema o condición detectada",
  "suggested_treatment": "Descripción del tratamiento recomendado",
  "confidence_percentage": 87.5
}

Donde:
- "diagnosis": string con el diagnóstico principal (ej: "Deficiencia de Nitrógeno", "Planta saludable", "Mancha foliar por hongo").
- "suggested_treatment": string con la acción recomendada para el agricultor.
- "confidence_percentage": número flotante entre 0 y 100 que representa tu nivel de certeza.
"""


# ---------------------------------------------------------------------------
# Función Principal del Servicio
# ---------------------------------------------------------------------------

async def analyze_plant_image(image_bytes: bytes, mime_type: str = "image/jpeg") -> dict:
    """
    Envía los bytes de una imagen a Gemini Vision y devuelve el diagnóstico.

    Args:
        image_bytes: Los bytes crudos de la imagen de la planta.
        mime_type: El tipo MIME de la imagen (por defecto "image/jpeg").

    Returns:
        Un diccionario con las claves:
        - diagnosis (str)
        - suggested_treatment (str)
        - confidence_percentage (float)

    Raises:
        HTTPException 503: Si la API de Gemini no responde o hay un error de red.
        HTTPException 502: Si Gemini responde con un formato JSON inesperado.
    """
    # --- Mock para desarrollo (evita llamadas reales a Gemini) ---
    # Cambiar a False para usar Gemini real cuando el quota esté disponible.
    _USE_MOCK = True
    if _USE_MOCK:
        return {
            "diagnosis": "Deficiencia de Nitrógeno",
            "suggested_treatment": (
                "Aplicar fertilizante nitrogenado (urea o nitrato de amonio) "
                "diluido en agua. Regar en las horas de menor temperatura."
            ),
            "confidence_percentage": 82.5,
        }

    # --- Llamada a la API de Gemini (async para no bloquear el event loop) ---
    try:
        image_part = {"mime_type": mime_type, "data": image_bytes}
        response = await _model.generate_content_async([_DIAGNOSIS_PROMPT, image_part])
        raw_text = response.text.strip()

    except Exception as exc:
        # Captura cualquier error de red, timeout o de la API de Gemini.
        logger.error("Error al contactar la API de Gemini: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="El servicio de diagnóstico IA no está disponible. Intenta más tarde.",
        ) from exc

    # --- Parseo y Validación del JSON ---
    try:
        # Limpiamos posibles bloques de código markdown que Gemini pueda incluir
        # a pesar de la instrucción estricta (ej: ```json ... ```)
        if raw_text.startswith("```"):
            raw_text = raw_text.split("```")[1]
            if raw_text.startswith("json"):
                raw_text = raw_text[4:]

        diagnosis_data = json.loads(raw_text)

        # Validamos que las claves requeridas estén presentes
        required_keys = {"diagnosis", "suggested_treatment", "confidence_percentage"}
        if not required_keys.issubset(diagnosis_data.keys()):
            raise ValueError(f"Claves faltantes en la respuesta: {required_keys - diagnosis_data.keys()}")

        return {
            "diagnosis": str(diagnosis_data["diagnosis"]),
            "suggested_treatment": str(diagnosis_data["suggested_treatment"]),
            "confidence_percentage": float(diagnosis_data["confidence_percentage"]),
        }

    except (json.JSONDecodeError, ValueError, KeyError) as exc:
        # Si el formato es inesperado, logueamos el texto crudo para depuración.
        logger.error(
            "Gemini devolvió un formato inesperado. Raw text: %r | Error: %s",
            raw_text,
            exc,
        )
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="La IA devolvió una respuesta en formato inválido. Por favor, intenta con otra imagen.",
        ) from exc
