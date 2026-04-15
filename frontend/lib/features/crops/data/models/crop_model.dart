import 'package:urban_smart_farming/features/crops/domain/entities/crop_entity.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/crop_profile.dart';

/// Convierte un row de Supabase (join Crop + CropProfile) a [CropEntity].
/// No adjunta hardware simulado — eso es responsabilidad del repositorio.
class CropModel {
  static CropEntity fromJson(Map<String, dynamic> json) {
    final id        = json['id'] as String;
    final name      = (json['custom_name'] as String?) ?? '';
    final location  = (json['location'] as String?) ?? '';
    final healthStr = (json['health_status'] as String?) ?? 'healthy';

    final createdAt = json['planting_date'] != null
        ? DateTime.parse(json['planting_date'] as String)
        : DateTime.parse(json['created_at'] as String);

    final updatedAt = json['updated_at'] != null
        ? DateTime.tryParse(json['updated_at'] as String)
        : null;

    final profileJson = json['CropProfile'] as Map<String, dynamic>?;
    final profile     = _resolveProfile(profileJson);
    final plantType   = profileJson != null
        ? (profileJson['profile_name'] as String? ?? profile.name)
        : profile.name;

    return CropEntity(
      id:        id,
      name:      name,
      plantType: plantType,
      location:  location,
      createdAt: createdAt,
      lastUpdate: updatedAt,
      status:    _mapStatus(healthStr),
      profile:   profile,
      pot:       null, // el repositorio adjunta MockPotFactory
    );
  }

  static CropStatus _mapStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'paused':
        return CropStatus.paused;
      case 'archived':
        return CropStatus.archived;
      default:
        return CropStatus.active;
    }
  }

  static PlantProfile _resolveProfile(Map<String, dynamic>? json) {
    if (json == null) return _fallback('unknown', 'Desconocido');

    final profileName = (json['profile_name'] as String?) ?? '';

    // 1. Coincidencia por ID en inglés (e.g. 'tomatoes', 'lettuce')
    final byId = PredefinedProfiles.getById(profileName.toLowerCase());
    if (byId != null) return byId;

    // 2. Coincidencia por nombre en español (e.g. 'Tomates', 'Lechugas')
    final byName = PredefinedProfiles.profiles
        .cast<PlantProfile?>()
        .firstWhere(
          (p) => p!.name.toLowerCase() == profileName.toLowerCase(),
          orElse: () => null,
        );
    if (byName != null) return byName;

    // 3. Perfil parcial desde los campos disponibles en el DB
    final dbId = (json['id'] as String?) ?? 'db-${profileName.hashCode}';
    return PlantProfile(
      id:                 dbId,
      name:               profileName,
      description:        'Perfil importado desde base de datos',
      minSoilMoisture:    (json['min_moisture']      as num?)?.toDouble() ?? 50.0,
      maxSoilMoisture:    (json['max_moisture']      as num?)?.toDouble() ?? 80.0,
      minTemperature:     (json['ideal_temperature'] as num?)?.toDouble() ?? 15.0,
      maxTemperature:     (json['ideal_temperature'] as num?)?.toDouble() ?? 30.0,
      minPH:              6.0,
      maxPH:              7.5,
      requiredLightHours: 6,
      optimalLux:         8000,
      isPredefined:       false,
    );
  }

  static PlantProfile _fallback(String id, String name) => PlantProfile(
        id:                 id,
        name:               name,
        description:        'Perfil por defecto',
        minSoilMoisture:    50,
        maxSoilMoisture:    80,
        minTemperature:     15,
        maxTemperature:     30,
        minPH:              6.0,
        maxPH:              7.5,
        requiredLightHours: 6,
        optimalLux:         8000,
      );
}
