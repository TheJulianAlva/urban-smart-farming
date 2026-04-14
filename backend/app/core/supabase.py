"""
Cliente Singleton de Supabase.

Implementa el Patrón Singleton documentado en el SADD (Sección 3) para
garantizar que exista una única conexión activa a la base de datos durante
todo el ciclo de vida de la aplicación FastAPI.

Uso desde cualquier router o servicio:
    from app.core.supabase import supabase_client
"""

from supabase import Client, create_client

from app.core.config import settings

# ---------------------------------------------------------------------------
# Inicialización del cliente
# ---------------------------------------------------------------------------

supabase_client: Client = create_client(
    supabase_url=settings.supabase_url,
    supabase_key=settings.supabase_key,
)
