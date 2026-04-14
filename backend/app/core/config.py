"""
Gestión centralizada de la configuración y variables de entorno.

Utiliza pydantic-settings para cargar y validar automáticamente
las variables definidas en el archivo .env antes de que el servidor arranque.
Si una variable obligatoria falta, la aplicación no iniciará y mostrará
un error descriptivo, evitando fallos silenciosos en producción.
"""

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """
    Define todas las variables de entorno requeridas por el sistema.
    Pydantic las validará al iniciar la aplicación.
    """

    # --- Supabase ---
    supabase_url: str
    supabase_key: str

    # --- Broker MQTT ---
    mqtt_broker_host: str
    mqtt_broker_port: int = 8883
    mqtt_username: str
    mqtt_password: str

    # --- Gemini Vision AI ---
    gemini_api_key: str

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
    )


# Instancia única exportable.
# El resto de la aplicación importa este objeto directamente.
settings = Settings()
