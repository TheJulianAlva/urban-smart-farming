/// Entidad que representa un perfil de configuración para cultivos
class CropProfile {
  final String id;
  final String name;
  final String description;
  final double minHumidity; // Porcentaje mínimo de humedad
  final double maxHumidity; // Porcentaje máximo de humedad
  final double minTemperature; // Temperatura mínima en °C
  final double maxTemperature; // Temperatura máxima en °C
  final int requiredLightHours; // Horas de luz requeridas por día
  final bool isPredefined; // Si es un perfil predefinido o personalizado

  const CropProfile({
    required this.id,
    required this.name,
    required this.description,
    required this.minHumidity,
    required this.maxHumidity,
    required this.minTemperature,
    required this.maxTemperature,
    required this.requiredLightHours,
    this.isPredefined = false,
  });

  CropProfile copyWith({
    String? id,
    String? name,
    String? description,
    double? minHumidity,
    double? maxHumidity,
    double? minTemperature,
    double? maxTemperature,
    int? requiredLightHours,
    bool? isPredefined,
  }) {
    return CropProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      minHumidity: minHumidity ?? this.minHumidity,
      maxHumidity: maxHumidity ?? this.maxHumidity,
      minTemperature: minTemperature ?? this.minTemperature,
      maxTemperature: maxTemperature ?? this.maxTemperature,
      requiredLightHours: requiredLightHours ?? this.requiredLightHours,
      isPredefined: isPredefined ?? this.isPredefined,
    );
  }
}

/// Catálogo de perfiles predefinidos para plantas comunes
class PredefinedProfiles {
  static const List<CropProfile> profiles = [
    CropProfile(
      id: 'tomatoes',
      name: 'Tomates',
      description:
          'Mantiene humedad constante entre 60-80% y temperatura óptima de 18-25°C',
      minHumidity: 60,
      maxHumidity: 80,
      minTemperature: 18,
      maxTemperature: 25,
      requiredLightHours: 8,
      isPredefined: true,
    ),
    CropProfile(
      id: 'lettuce',
      name: 'Lechugas',
      description:
          'Requiere humedad alta (70-85%) y temperaturas frescas de 15-20°C',
      minHumidity: 70,
      maxHumidity: 85,
      minTemperature: 15,
      maxTemperature: 20,
      requiredLightHours: 6,
      isPredefined: true,
    ),
    CropProfile(
      id: 'basil',
      name: 'Albahaca',
      description:
          'Necesita humedad moderada (50-70%) y clima cálido de 20-30°C',
      minHumidity: 50,
      maxHumidity: 70,
      minTemperature: 20,
      maxTemperature: 30,
      requiredLightHours: 6,
      isPredefined: true,
    ),
    CropProfile(
      id: 'cactus',
      name: 'Cactus',
      description:
          'Requiere poca agua (20-40%) y tolera altas temperaturas 25-35°C',
      minHumidity: 20,
      maxHumidity: 40,
      minTemperature: 25,
      maxTemperature: 35,
      requiredLightHours: 10,
      isPredefined: true,
    ),
    CropProfile(
      id: 'strawberry',
      name: 'Fresas',
      description:
          'Humedad media-alta (60-75%) con temperaturas moderadas 15-25°C',
      minHumidity: 60,
      maxHumidity: 75,
      minTemperature: 15,
      maxTemperature: 25,
      requiredLightHours: 8,
      isPredefined: true,
    ),
  ];

  static CropProfile? getById(String id) {
    try {
      return profiles.firstWhere((profile) => profile.id == id);
    } catch (e) {
      return null;
    }
  }
}
