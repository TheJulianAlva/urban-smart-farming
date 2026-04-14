/// Entidad que representa un perfil de configuración para cultivos
/// Renombrado a PlantProfile para mejor semántica
class PlantProfile {
  final String id;
  final String name;
  final String description;

  // Parámetros de humedad del suelo
  final double minSoilMoisture; // Porcentaje mínimo de humedad del suelo
  final double maxSoilMoisture; // Porcentaje máximo de humedad del suelo

  // Parámetros de temperatura ambiental
  final double minTemperature; // Temperatura mínima en °C
  final double maxTemperature; // Temperatura máxima en °C

  // Parámetros de pH del suelo
  final double minPH; // pH mínimo
  final double maxPH; // pH máximo

  // Parámetros de iluminación
  final int requiredLightHours; // Horas de luz requeridas por día
  final int optimalLux; // Lux óptimos

  final bool isPredefined; // Si es un perfil predefinido o personalizado

  const PlantProfile({
    required this.id,
    required this.name,
    required this.description,
    required this.minSoilMoisture,
    required this.maxSoilMoisture,
    required this.minTemperature,
    required this.maxTemperature,
    required this.minPH,
    required this.maxPH,
    required this.requiredLightHours,
    required this.optimalLux,
    this.isPredefined = false,
  });

  PlantProfile copyWith({
    String? id,
    String? name,
    String? description,
    double? minSoilMoisture,
    double? maxSoilMoisture,
    double? minTemperature,
    double? maxTemperature,
    double? minPH,
    double? maxPH,
    int? requiredLightHours,
    int? optimalLux,
    bool? isPredefined,
  }) {
    return PlantProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      minSoilMoisture: minSoilMoisture ?? this.minSoilMoisture,
      maxSoilMoisture: maxSoilMoisture ?? this.maxSoilMoisture,
      minTemperature: minTemperature ?? this.minTemperature,
      maxTemperature: maxTemperature ?? this.maxTemperature,
      minPH: minPH ?? this.minPH,
      maxPH: maxPH ?? this.maxPH,
      requiredLightHours: requiredLightHours ?? this.requiredLightHours,
      optimalLux: optimalLux ?? this.optimalLux,
      isPredefined: isPredefined ?? this.isPredefined,
    );
  }

  // Helpers para validar rangos
  bool isTemperatureOptimal(double temp) =>
      temp >= minTemperature && temp <= maxTemperature;

  bool isSoilMoistureOptimal(double moisture) =>
      moisture >= minSoilMoisture && moisture <= maxSoilMoisture;

  bool isPHOptimal(double ph) => ph >= minPH && ph <= maxPH;

  bool isLightOptimal(int lux) => lux >= (optimalLux * 0.8);
}

// Mantener CropProfile como alias para compatibilidad
typedef CropProfile = PlantProfile;

/// Catálogo de perfiles predefinidos para plantas comunes
class PredefinedProfiles {
  static const List<PlantProfile> profiles = [
    PlantProfile(
      id: 'tomatoes',
      name: 'Tomates',
      description:
          'Mantiene humedad constante entre 60-80% y temperatura óptima de 18-28°C',
      minSoilMoisture: 60,
      maxSoilMoisture: 80,
      minTemperature: 18,
      maxTemperature: 28,
      minPH: 6.0,
      maxPH: 7.0,
      requiredLightHours: 8,
      optimalLux: 10000,
      isPredefined: true,
    ),
    PlantProfile(
      id: 'lettuce',
      name: 'Lechugas',
      description:
          'Requiere humedad alta (70-85%) y temperaturas frescas de 15-20°C',
      minSoilMoisture: 70,
      maxSoilMoisture: 85,
      minTemperature: 15,
      maxTemperature: 20,
      minPH: 6.0,
      maxPH: 7.0,
      requiredLightHours: 6,
      optimalLux: 8000,
      isPredefined: true,
    ),
    PlantProfile(
      id: 'basil',
      name: 'Albahaca',
      description:
          'Necesita humedad moderada (50-70%) y clima cálido de 20-30°C',
      minSoilMoisture: 50,
      maxSoilMoisture: 70,
      minTemperature: 20,
      maxTemperature: 30,
      minPH: 6.0,
      maxPH: 7.5,
      requiredLightHours: 6,
      optimalLux: 8000,
      isPredefined: true,
    ),
    PlantProfile(
      id: 'cactus',
      name: 'Cactus',
      description:
          'Requiere poca agua (20-40%) y tolera altas temperaturas 25-35°C',
      minSoilMoisture: 20,
      maxSoilMoisture: 40,
      minTemperature: 25,
      maxTemperature: 35,
      minPH: 6.5,
      maxPH: 8.0,
      requiredLightHours: 10,
      optimalLux: 12000,
      isPredefined: true,
    ),
    PlantProfile(
      id: 'strawberry',
      name: 'Fresas',
      description:
          'Humedad media-alta (60-75%) con temperaturas moderadas 15-25°C',
      minSoilMoisture: 60,
      maxSoilMoisture: 75,
      minTemperature: 15,
      maxTemperature: 25,
      minPH: 5.5,
      maxPH: 6.5,
      requiredLightHours: 8,
      optimalLux: 10000,
      isPredefined: true,
    ),
    PlantProfile(
      id: 'mint',
      name: 'Menta',
      description:
          'Planta aromática resistente, prefiere humedad alta y sombra parcial',
      minSoilMoisture: 65,
      maxSoilMoisture: 85,
      minTemperature: 15,
      maxTemperature: 25,
      minPH: 6.0,
      maxPH: 7.5,
      requiredLightHours: 4,
      optimalLux: 6000,
      isPredefined: true,
    ),
    PlantProfile(
      id: 'cilantro',
      name: 'Cilantro',
      description:
          'Hierba aromática de rápido crecimiento, necesita temperaturas frescas',
      minSoilMoisture: 60,
      maxSoilMoisture: 75,
      minTemperature: 15,
      maxTemperature: 22,
      minPH: 6.2,
      maxPH: 6.8,
      requiredLightHours: 5,
      optimalLux: 7000,
      isPredefined: true,
    ),
    PlantProfile(
      id: 'peppers',
      name: 'Pimientos',
      description: 'Vegetales coloridos que requieren calor y mucha luz solar',
      minSoilMoisture: 60,
      maxSoilMoisture: 75,
      minTemperature: 20,
      maxTemperature: 30,
      minPH: 6.0,
      maxPH: 7.0,
      requiredLightHours: 8,
      optimalLux: 11000,
      isPredefined: true,
    ),
    PlantProfile(
      id: 'spinach',
      name: 'Espinacas',
      description:
          'Vegetal de hoja verde, crece rápido en temperaturas frescas',
      minSoilMoisture: 65,
      maxSoilMoisture: 80,
      minTemperature: 10,
      maxTemperature: 20,
      minPH: 6.5,
      maxPH: 7.5,
      requiredLightHours: 5,
      optimalLux: 7500,
      isPredefined: true,
    ),
    PlantProfile(
      id: 'succulents',
      name: 'Suculentas',
      description:
          'Plantas ornamentales resistentes, requieren poca agua y mucha luz',
      minSoilMoisture: 20,
      maxSoilMoisture: 40,
      minTemperature: 15,
      maxTemperature: 30,
      minPH: 6.0,
      maxPH: 7.0,
      requiredLightHours: 6,
      optimalLux: 10000,
      isPredefined: true,
    ),
    PlantProfile(
      id: 'pothos',
      name: 'Pothos',
      description:
          'Planta de interior popular, tolera poca luz y es fácil de cuidar',
      minSoilMoisture: 50,
      maxSoilMoisture: 70,
      minTemperature: 18,
      maxTemperature: 27,
      minPH: 6.0,
      maxPH: 7.5,
      requiredLightHours: 3,
      optimalLux: 4000,
      isPredefined: true,
    ),
    PlantProfile(
      id: 'rosemary',
      name: 'Romero',
      description:
          'Hierba aromática mediterránea, prefiere suelo seco y mucha luz',
      minSoilMoisture: 30,
      maxSoilMoisture: 50,
      minTemperature: 15,
      maxTemperature: 28,
      minPH: 6.0,
      maxPH: 7.5,
      requiredLightHours: 7,
      optimalLux: 10000,
      isPredefined: true,
    ),
    PlantProfile(
      id: 'parsley',
      name: 'Perejil',
      description:
          'Hierba aromática versátil, perfecta para cocina, crece bien en interior',
      minSoilMoisture: 60,
      maxSoilMoisture: 75,
      minTemperature: 15,
      maxTemperature: 24,
      minPH: 6.0,
      maxPH: 7.0,
      requiredLightHours: 5,
      optimalLux: 7500,
      isPredefined: true,
    ),
    PlantProfile(
      id: 'lavender',
      name: 'Lavanda',
      description:
          'Planta ornamental aromática con flores moradas, requiere poca agua y mucha luz',
      minSoilMoisture: 25,
      maxSoilMoisture: 45,
      minTemperature: 15,
      maxTemperature: 30,
      minPH: 6.5,
      maxPH: 8.0,
      requiredLightHours: 8,
      optimalLux: 11000,
      isPredefined: true,
    ),
    PlantProfile(
      id: 'thyme',
      name: 'Tomillo',
      description:
          'Hierba aromática mediterránea, resistente y perfecta para cocina',
      minSoilMoisture: 30,
      maxSoilMoisture: 50,
      minTemperature: 15,
      maxTemperature: 28,
      minPH: 6.0,
      maxPH: 8.0,
      requiredLightHours: 6,
      optimalLux: 9000,
      isPredefined: true,
    ),
  ];

  static PlantProfile? getById(String id) {
    try {
      return profiles.firstWhere((profile) => profile.id == id);
    } catch (e) {
      return null;
    }
  }
}
