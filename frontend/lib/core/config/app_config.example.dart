/// Plantilla de configuración.
class AppConfig {
  static const supabaseUrl = 'https://TU_PROYECTO.supabase.co';

  static const supabaseAnonKey = 'TU_ANON_KEY';

  /// URL base del backend (según entorno)
  /// Desarrollo con dispositivo físico: usar la IP local de tu PC en la red WiFi
  /// Emulador Android: usar http://10.0.2.2:8000
  /// Producción: usar la URL del servidor desplegado
  static const backendBaseUrl = 'http://TU_IP_LOCAL:8000';
}
