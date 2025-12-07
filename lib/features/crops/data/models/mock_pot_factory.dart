import 'dart:math';
import 'package:urban_smart_farming/features/crops/domain/entities/pot.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/sensor.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/actuator.dart';

/// Factory para generar datos mockup de macetas con sensores
class MockPotFactory {
  static final Random _random = Random();

  /// Genera una maceta mockup completa con sensores y actuadores
  static Pot createMockPot({
    required String id,
    required String cropId,
    String? hardwareName,
  }) {
    final now = DateTime.now();

    return Pot(
      id: id,
      hardwareId: 'ESP32-${_generateHexId()}',
      name: hardwareName ?? 'Módulo ${id.substring(0, 4).toUpperCase()}',
      installedAt: now.subtract(Duration(days: _random.nextInt(90))),
      isConnected: _random.nextDouble() > 0.1, // 90% conectado
      lastSync: now.subtract(Duration(minutes: _random.nextInt(30))),
      sensors: _createMockSensors(),
      actuators: _createMockActuators(),
    );
  }

  /// Genera sensores mockup con valores realistas
  static List<Sensor> _createMockSensors() {
    final now = DateTime.now();
    final hourOfDay = now.hour;

    return [
      // Sensor de temperatura (varía con hora del día)
      Sensor(
        id: 'sensor-temp-${_generateHexId()}',
        type: SensorType.temperature,
        pin: 'A0',
        currentValue: _getRealisticTemperature(hourOfDay),
        lastReading: now.subtract(Duration(seconds: _random.nextInt(60))),
        isActive: true,
        unit: '°C',
      ),

      // Sensor de humedad del suelo (decae con tiempo)
      Sensor(
        id: 'sensor-moist-${_generateHexId()}',
        type: SensorType.soilMoisture,
        pin: 'A1',
        currentValue: _getRealisticSoilMoisture(),
        lastReading: now.subtract(Duration(seconds: _random.nextInt(60))),
        isActive: true,
        unit: '%',
      ),

      // Sensor de pH (relativamente estable)
      Sensor(
        id: 'sensor-ph-${_generateHexId()}',
        type: SensorType.ph,
        currentValue: _getRealisticPH(),
        lastReading: now.subtract(Duration(seconds: _random.nextInt(60))),
        isActive: true,
        unit: 'pH',
        pin: 'A2',
      ),

      // Sensor de luz (varía según hora)
      Sensor(
        id: 'sensor-light-${_generateHexId()}',
        type: SensorType.light,
        currentValue: _getRealisticLight(hourOfDay),
        lastReading: now.subtract(Duration(seconds: _random.nextInt(60))),
        isActive: true,
        unit: 'lux',
        pin: 'A3',
      ),
    ];
  }

  /// Genera actuadores mockup
  static List<Actuator> _createMockActuators() {
    final now = DateTime.now();

    return [
      // Bomba de riego
      Actuator(
        id: 'actuator-pump-${_generateHexId()}',
        type: ActuatorType.waterPump,
        pin: 'D5',
        isOn: _random.nextDouble() > 0.9, // 10% probabilidad encendido
        lastActivation: now.subtract(Duration(hours: _random.nextInt(24))),
        isActive: true,
      ),

      // Luz LED
      Actuator(
        id: 'actuator-led-${_generateHexId()}',
        type: ActuatorType.ledLight,
        pin: 'D6',
        isOn: _random.nextDouble() > 0.5,
        intensity: 60 + _random.nextInt(40), // 60-100%
        lastActivation: now.subtract(Duration(minutes: _random.nextInt(120))),
        isActive: true,
      ),
    ];
  }

  /// Temperatura realista que varía con hora del día (18-28°C)
  static double _getRealisticTemperature(int hour) {
    // Ciclo sinusoidal: mínimo a las 6am, máximo a las 2pm
    final baseTemp = 23.0;
    final variation = 5.0 * sin((hour - 6) * pi / 12);
    final noise = (_random.nextDouble() - 0.5) * 1.0;
    return (baseTemp + variation + noise).clamp(15.0, 35.0);
  }

  /// Humedad del suelo realista (30-85%)
  static double _getRealisticSoilMoisture() {
    // Distribución normal centrada en 65%
    final baseMoisture = 65.0;
    final variation = (_random.nextDouble() - 0.5) * 30;
    return (baseMoisture + variation).clamp(25.0, 90.0);
  }

  /// pH realista (6.0-7.5)
  static double _getRealisticPH() {
    final basePH = 6.5;
    final variation = (_random.nextDouble() - 0.5) * 1.0;
    return (basePH + variation).clamp(5.5, 8.0);
  }

  /// Luz realista según hora del día (0-12000 lux)
  static double _getRealisticLight(int hour) {
    // Ciclo día/noche
    if (hour < 6 || hour > 20) {
      return _random.nextDouble() * 100; // Luz artificial mínima
    }

    // Máximo al mediodía
    final maxLux = 12000.0;
    final variation = sin((hour - 6) * pi / 14);
    final noise = (_random.nextDouble() - 0.5) * 1000;
    return (maxLux * variation + noise).clamp(0.0, 15000.0);
  }

  /// Genera un ID hexadecimal aleatorio
  static String _generateHexId() {
    return _random
        .nextInt(0xFFFFFF)
        .toRadixString(16)
        .padLeft(6, '0')
        .toUpperCase();
  }

  /// Crea una maceta sin hardware (para cultivos sin sensores)
  static Pot? createNoPot() {
    return null;
  }
}
