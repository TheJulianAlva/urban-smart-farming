abstract class ControlRepository {
  /// Devuelve el device_id asociado al crop, o null si no tiene dispositivo.
  Future<String?> getDeviceId(String cropId);

  /// Retorna el último estado conocido de bomba y luz desde ActuationEvent.
  Future<({bool isPumpOn, bool isLightOn})> getActuatorStates(String deviceId);

  /// Envía comando al backend. Lanza excepción si falla.
  Future<void> actuate(String deviceId, String actuatorType, String action);
}
