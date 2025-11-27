import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:urban_smart_farming/core/utils/constants.dart';
import 'package:urban_smart_farming/core/utils/failures.dart';
import 'package:urban_smart_farming/features/dashboard/domain/entities/sensor_reading_entity.dart';
import 'package:urban_smart_farming/features/dashboard/domain/entities/actuator_status_entity.dart';
import 'package:urban_smart_farming/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Implementación mock del repositorio de dashboard
class DashboardRepositoryImpl implements DashboardRepository {
  // Map de actuadores por cultivo
  final Map<String, List<ActuatorStatusEntity>> _actuatorsByCrop = {
    '1': [
      ActuatorStatusEntity(
        id: '1-1',
        cropId: '1',
        name: 'Bomba de Riego',
        type: ActuatorType.pump,
        isOn: false,
        lastUpdate: DateTime.now(),
      ),
      ActuatorStatusEntity(
        id: '1-2',
        cropId: '1',
        name: 'Luz LED',
        type: ActuatorType.light,
        isOn: true,
        lastUpdate: DateTime.now(),
      ),
    ],
    '2': [
      ActuatorStatusEntity(
        id: '2-1',
        cropId: '2',
        name: 'Bomba Hidropónica',
        type: ActuatorType.pump,
        isOn: true,
        lastUpdate: DateTime.now(),
      ),
      ActuatorStatusEntity(
        id: '2-2',
        cropId: '2',
        name: 'Luz de Crecimiento',
        type: ActuatorType.light,
        isOn: true,
        lastUpdate: DateTime.now(),
      ),
    ],
    '3': [
      ActuatorStatusEntity(
        id: '3-1',
        cropId: '3',
        name: 'Riego por Goteo',
        type: ActuatorType.pump,
        isOn: false,
        lastUpdate: DateTime.now(),
      ),
    ],
  };

  @override
  Future<Either<Failure, SensorReadingEntity>> getSensorReadings(
    String cropId,
  ) async {
    // Simular latencia
    await Future.delayed(const Duration(milliseconds: 500));

    // Generar valores diferentes según el cultivo
    final seed = cropId.hashCode;
    final cropRandom = Random(seed + DateTime.now().millisecondsSinceEpoch);

    // Rangos base diferentes por cultivo para variedad
    double tempBase, humidityBase, lightBase, phBase;

    switch (cropId) {
      case '1': // Tomates - prefieren más calor
        tempBase = 24.0;
        humidityBase = 55.0;
        lightBase = 600.0;
        phBase = 6.0;
        break;
      case '2': // Lechugas - prefieren más frescura
        tempBase = 21.0;
        humidityBase = 65.0;
        lightBase = 400.0;
        phBase = 6.2;
        break;
      case '3': // Albahaca - condiciones moderadas
        tempBase = 23.0;
        humidityBase = 60.0;
        lightBase = 500.0;
        phBase = 6.5;
        break;
      default:
        tempBase = 22.0;
        humidityBase = 60.0;
        lightBase = 500.0;
        phBase = 6.3;
    }

    // Agregar variación
    final temp = tempBase + (cropRandom.nextDouble() - 0.5) * 4.0;
    final humidity = humidityBase + (cropRandom.nextDouble() - 0.5) * 10.0;
    final light = lightBase + (cropRandom.nextDouble() - 0.5) * 200.0;
    final ph = phBase + (cropRandom.nextDouble() - 0.5) * 0.8;

    final reading = SensorReadingEntity(
      cropId: cropId,
      temperature: temp,
      humidity: humidity,
      lightLevel: light,
      ph: ph,
      timestamp: DateTime.now(),
      temperatureStatus: _getStatus(temp, 'temperature'),
      humidityStatus: _getStatus(humidity, 'humidity'),
      lightStatus: _getStatus(light, 'light'),
      phStatus: _getStatus(ph, 'ph'),
    );

    return Right(reading);
  }

  @override
  Future<Either<Failure, List<ActuatorStatusEntity>>> getActuatorStatuses(
    String cropId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Retornar actuadores del cultivo específico o lista vacía
    final actuators = _actuatorsByCrop[cropId] ?? [];
    return Right(List.from(actuators));
  }

  /// Determina el estado basado en los rangos óptimos
  SensorStatus _getStatus(double value, String metric) {
    final ranges = AppConstants.optimalRanges[metric];
    if (ranges == null) return SensorStatus.optimal;

    final min = ranges['min']!;
    final max = ranges['max']!;

    if (value < min * 0.8 || value > max * 1.2) {
      return SensorStatus.danger;
    } else if (value < min || value > max) {
      return SensorStatus.warning;
    } else {
      return SensorStatus.optimal;
    }
  }
}
