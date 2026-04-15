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

# Se usa el service role key para que el backend pueda operar sin restricciones
# de RLS. El anon key (supabase_key) es para el cliente Flutter con RLS activo.
supabase_client: Client = create_client(
    supabase_url=settings.supabase_url,
    supabase_key=settings.supabase_service_key,
)
