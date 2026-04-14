/// Constantes de la aplicación
class AppConstants {
  // Información de la app
  static const String appName = 'Urban Smart Farming';
  static const String appVersion = '1.0.0';

  // Tiempos de actualización (en segundos)
  static const int dashboardRefreshInterval = 10;
  static const int sensorDataTimeout = 30;

  // Rangos óptimos por defecto
  static const Map<String, Map<String, double>> optimalRanges = {
    'temperature': {'min': 20.0, 'max': 28.0},
    'humidity': {'min': 50.0, 'max': 65.0},
    'light': {'min': 400.0, 'max': 800.0},
    'ph': {'min': 5.5, 'max': 7.0},
  };

  // Validaciones
  static const int minPasswordLength = 6;
  static const int maxProfileNameLength = 50;

  // Duración de animaciones (milisegundos)
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 300;
  static const int longAnimationDuration = 500;
}
