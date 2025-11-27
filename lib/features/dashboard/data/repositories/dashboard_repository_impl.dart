import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:urban_smart_farming/core/utils/constants.dart';
import 'package:urban_smart_farming/core/utils/failures.dart';
import 'package:urban_smart_farming/features/dashboard/domain/entities/sensor_reading_entity.dart';
import 'package:urban_smart_farming/features/dashboard/domain/entities/actuator_status_entity.dart';
import 'package:urban_smart_farming/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Implementación mock del repositorio de dashboard
class DashboardRepositoryImpl implements DashboardRepository {
  final Random _random = Random();
  final List<ActuatorStatusEntity> _actuators = [
    ActuatorStatusEntity(
      id: '1',
      name: 'Bomba de Riego',
      type: ActuatorType.pump,
      isOn: false,
      lastUpdate: DateTime.now(),
    ),
    ActuatorStatusEntity(
      id: '2',
      name: 'Luz LED',
      type: ActuatorType.light,
      isOn: true,
      lastUpdate: DateTime.now(),
    ),
  ];

  @override
  Future<Either<Failure, SensorReadingEntity>> getSensorReadings() async {
    // Simular latencia
    await Future.delayed(const Duration(milliseconds: 500));

    // Generar valores aleatorios dentro de rangos realistas
    final temp = 20.0 + _random.nextDouble() * 8.0; // 20-28°C
    final humidity = 45.0 + _random.nextDouble() * 25.0; // 45-70%
    final light = 300.0 + _random.nextDouble() * 500.0; // 300-800 Lux
    final ph = 5.5 + _random.nextDouble() * 1.5; // 5.5-7.0

    final reading = SensorReadingEntity(
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
  Future<Either<Failure, List<ActuatorStatusEntity>>>
  getActuatorStatuses() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Right(List.from(_actuators));
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
