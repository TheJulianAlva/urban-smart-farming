import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urban_smart_farming/core/di/di_container.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/crops_bloc.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/crops_event.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/crops_state.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/crop_entity.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/actuator.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/sensor.dart';

/// Pantalla de control de actuadores (riego, LED)
class ControlScreen extends StatelessWidget {
  final String cropId;

  const ControlScreen({super.key, required this.cropId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Control'), elevation: 0),
      body: BlocBuilder<CropsBloc, CropsState>(
        bloc: getIt<CropsBloc>()..add(LoadCrops()),
        builder: (context, state) {
          if (state is CropsLoaded) {
            try {
              final crop = state.crops.firstWhere((c) => c.id == cropId);

              if (!crop.hasHardware) {
                return _buildNoHardware(context);
              }

              return _buildControlPanel(context, crop);
            } catch (e) {
              return _buildError(context);
            }
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildControlPanel(BuildContext context, CropEntity crop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con info del cultivo
          _buildCropHeader(context, crop),
          const SizedBox(height: 24),

          // Estado de sensores (contexto)
          Text(
            'Estado Actual',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildSensorsSummary(context, crop),
          const SizedBox(height: 32),

          // Controles de actuadores
          Text(
            'Controles',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ..._buildActuatorControls(context, crop),
        ],
      ),
    );
  }

  Widget _buildCropHeader(BuildContext context, CropEntity crop) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.eco,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    crop.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    crop.plantType,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    crop.pot!.isConnected ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    crop.pot!.isConnected ? Icons.wifi : Icons.wifi_off,
                    size: 16,
                    color:
                        crop.pot!.isConnected
                            ? Colors.green[700]
                            : Colors.red[700],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    crop.pot!.isConnected ? 'Conectado' : 'Desconectado',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color:
                          crop.pot!.isConnected
                              ? Colors.green[700]
                              : Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorsSummary(BuildContext context, CropEntity crop) {
    return Row(
      children: [
        Expanded(
          child: _buildMiniSensorCard(
            context,
            crop.getSensor(SensorType.temperature),
            Icons.thermostat,
            'Temperatura',
            '${crop.profile.minTemperature.toInt()}-${crop.profile.maxTemperature.toInt()}°C',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniSensorCard(
            context,
            crop.getSensor(SensorType.soilMoisture),
            Icons.water_drop,
            'Humedad',
            '${crop.profile.minSoilMoisture.toInt()}-${crop.profile.maxSoilMoisture.toInt()}%',
          ),
        ),
      ],
    );
  }

  Widget _buildMiniSensorCard(
    BuildContext context,
    Sensor? sensor,
    IconData icon,
    String label,
    String optimal,
  ) {
    final value =
        sensor?.currentValue != null
            ? '${sensor!.currentValue!.toStringAsFixed(1)}${sensor.unit}'
            : 'N/A';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Óptimo: $optimal',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActuatorControls(BuildContext context, CropEntity crop) {
    final actuators = <Widget>[];

    // Bomba de agua
    final waterPump = crop.getActuator(ActuatorType.waterPump);
    if (waterPump != null) {
      actuators.add(
        ActuatorControlCard(
          actuator: waterPump,
          relatedSensor: crop.getSensor(SensorType.soilMoisture),
          profile: crop.profile,
        ),
      );
      actuators.add(const SizedBox(height: 16));
    }

    // Luz LED
    final ledLight = crop.getActuator(ActuatorType.ledLight);
    if (ledLight != null) {
      actuators.add(
        ActuatorControlCard(
          actuator: ledLight,
          relatedSensor: crop.getSensor(SensorType.light),
          profile: crop.profile,
        ),
      );
    }

    return actuators;
  }

  Widget _buildNoHardware(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sensors_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Sin Hardware Vinculado',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Este cultivo no tiene actuadores para controlar',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Error al cargar datos'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }
}

/// Card de control individual para cada actuador
class ActuatorControlCard extends StatefulWidget {
  final Actuator actuator;
  final Sensor? relatedSensor;
  final profile;

  const ActuatorControlCard({
    super.key,
    required this.actuator,
    this.relatedSensor,
    required this.profile,
  });

  @override
  State<ActuatorControlCard> createState() => _ActuatorControlCardState();
}

class _ActuatorControlCardState extends State<ActuatorControlCard> {
  late bool _isOn;
  late int _intensity;

  @override
  void initState() {
    super.initState();
    _isOn = widget.actuator.isOn;
    _intensity = widget.actuator.intensity ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del actuador
            Row(
              children: [
                Icon(
                  _getActuatorIcon(),
                  size: 32,
                  color:
                      _isOn
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getActuatorName(),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Estado: ${_isOn ? "Encendido" : "Apagado"}${widget.actuator.hasIntensityControl ? " (${_intensity}%)" : ""}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isOn,
                  onChanged: (value) {
                    setState(() => _isOn = value);
                    _showConfirmation(value ? 'activado' : 'desactivado');
                  },
                ),
              ],
            ),

            const Divider(height: 24),

            // Contexto del sensor relacionado
            if (widget.relatedSensor != null) ...[
              _buildSensorContext(),
              const SizedBox(height: 16),
            ],

            // Control de intensidad (solo LED)
            if (widget.actuator.hasIntensityControl && _isOn) ...[
              const SizedBox(height: 8),
              _buildIntensityControl(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSensorContext() {
    final sensor = widget.relatedSensor!;
    final value = sensor.currentValue?.toStringAsFixed(1) ?? 'N/A';
    final isWaterPump = widget.actuator.type == ActuatorType.waterPump;
    final optimalRange =
        isWaterPump
            ? '${widget.profile.minSoilMoisture.toInt()}-${widget.profile.maxSoilMoisture.toInt()}%'
            : '${widget.profile.optimalLux} lux';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWaterPump ? 'Humedad del suelo' : 'Nivel de luz',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[900],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Actual: $value${sensor.unit} | Óptimo: $optimalRange',
                  style: TextStyle(fontSize: 11, color: Colors.blue[800]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntensityControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Intensidad: $_intensity%',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _intensity.toDouble(),
          min: 0,
          max: 100,
          divisions: 20,
          label: '$_intensity%',
          onChanged: (value) {
            setState(() => _intensity = value.toInt());
          },
          onChangeEnd: (value) {
            _showConfirmation('ajustado a ${value.toInt()}%');
          },
        ),
      ],
    );
  }

  IconData _getActuatorIcon() {
    switch (widget.actuator.type) {
      case ActuatorType.waterPump:
        return Icons.water_drop;
      case ActuatorType.ledLight:
        return Icons.lightbulb;
    }
  }

  String _getActuatorName() {
    switch (widget.actuator.type) {
      case ActuatorType.waterPump:
        return 'Sistema de Riego';
      case ActuatorType.ledLight:
        return 'Luz LED';
    }
  }

  void _showConfirmation(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_getActuatorName()} $action'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
