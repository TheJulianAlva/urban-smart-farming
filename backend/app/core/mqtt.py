"""
Cliente Singleton del Broker MQTT.

Implementa el Patrón Singleton para
mantener una única conexión persistente al Broker MQTT durante el ciclo
de vida de la aplicación. Usar múltiples clientes consumiría puertos y
recursos del servidor innecesariamente.

Incluye los callbacks base para manejar eventos de conexión y mensajes
entrantes. Los servicios específicos extienden este cliente suscribiéndose
a sus tópicos correspondientes.

Uso desde cualquier servicio:
    from app.core.mqtt import mqtt_client
"""

import logging

import paho.mqtt.client as mqtt

from app.core.config import settings

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Callbacks del ciclo de vida de la conexión MQTT
# ---------------------------------------------------------------------------


def _on_connect(client: mqtt.Client, userdata, flags, reason_code, properties):
    """
    Se ejecuta automáticamente cuando el cliente establece conexión con el Broker.
    Registra el resultado para facilitar el diagnóstico de errores de red.
    """
    if reason_code == 0:
        logger.info("Conexión al Broker MQTT establecida correctamente.")
    else:
        logger.error("Fallo al conectar al Broker MQTT. Código de razón: %s", reason_code)


def _on_disconnect(client: mqtt.Client, userdata, flags, reason_code, properties):
    """
    Se ejecuta cuando la conexión con el Broker se interrumpe.
    """
    logger.warning("Conexión MQTT desconectada. Código: %s", reason_code)


def _on_message(client: mqtt.Client, userdata, message: mqtt.MQTTMessage):
    """
    Callback base para mensajes entrantes.
    Los servicios específicos registrarán sus propios callbacks por tópico.
    """
    logger.debug(
        "Mensaje recibido en tópico '%s': %s",
        message.topic,
        message.payload.decode("utf-8"),
    )


# ---------------------------------------------------------------------------
# Configuración e inicialización del cliente
# ---------------------------------------------------------------------------

_client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
_client.username_pw_set(settings.mqtt_username, settings.mqtt_password)
_client.tls_set()  # MQTTS: habilita TLS/SSL

_client.on_connect = _on_connect
_client.on_disconnect = _on_disconnect
_client.on_message = _on_message

# Exportable para los servicios del dominio.
mqtt_client: mqtt.Client = _client
