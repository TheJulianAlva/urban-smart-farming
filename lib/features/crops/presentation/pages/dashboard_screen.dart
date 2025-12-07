import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:urban_smart_farming/core/di/di_container.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/crops_bloc.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/crops_state.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/crops_event.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/crop_entity.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/sensor.dart';
import 'package:urban_smart_farming/features/crops/presentation/widgets/sensor_gauge.dart';
import 'package:urban_smart_farming/features/crops/presentation/pages/control_screen.dart';

/// Pantalla de Dashboard que muestra el estado de un cultivo específico
class DashboardScreen extends StatelessWidget {
  final String cropId;

  const DashboardScreen({super.key, required this.cropId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CropsBloc>()..add(LoadCrops()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard del Cultivo'),
          elevation: 0,
        ),
        body: BlocBuilder<CropsBloc, CropsState>(
          builder: (context, state) {
            if (state is CropsLoaded) {
              try {
                final crop = state.crops.firstWhere((c) => c.id == cropId);
                return _buildDashboard(context, crop);
              } catch (e) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Cultivo no encontrado',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Volver'),
                      ),
                    ],
                  ),
                );
              }
            }

            if (state is CropsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CropsBloc>().add(LoadCrops());
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, CropEntity crop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información básica del cultivo
          _buildCropHeader(context, crop),
          const SizedBox(height: 24),

          // Sensores (si tiene hardware)
          if (crop.hasHardware) ...[
            _buildSectionTitle(context, 'Sensores en Tiempo Real'),
            const SizedBox(height: 16),
            _buildSensorsGrid(context, crop),
          ] else ...[
            _buildNoHardwareCard(context),
          ],

          // Botón de control (si tiene hardware)
          if (crop.hasHardware) ...[
            const SizedBox(height: 24),
            _buildControlButton(context, crop),
          ],

          const SizedBox(height: 24),

          // Información del perfil
          _buildSectionTitle(context, 'Perfil de la Planta'),
          const SizedBox(height: 16),
          _buildProfileInfo(context, crop),
        ],
      ),
    );
  }

  Widget _buildCropHeader(BuildContext context, CropEntity crop) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.eco,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    crop.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    crop.plantType,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        crop.location,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Indicador de conexión
            if (crop.hasHardware)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      crop.pot!.isConnected
                          ? Colors.green[100]
                          : Colors.red[100],
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

  Widget _buildSensorsGrid(BuildContext context, CropEntity crop) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.9,
      children: [
        SensorGauge(
          sensor: crop.getSensor(SensorType.temperature),
          profile: crop.profile,
        ),
        SensorGauge(
          sensor: crop.getSensor(SensorType.soilMoisture),
          profile: crop.profile,
        ),
        SensorGauge(
          sensor: crop.getSensor(SensorType.ph),
          profile: crop.profile,
        ),
        SensorGauge(
          sensor: crop.getSensor(SensorType.light),
          profile: crop.profile,
        ),
      ],
    );
  }

  Widget _buildNoHardwareCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.sensors_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Sin Maceta Inteligente',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Este cultivo no tiene sensores vinculados.\nConecta una maceta inteligente para ver datos en tiempo real.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navegar a pantalla de vincular hardware
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Función próximamente disponible'),
                  ),
                );
              },
              icon: const Icon(Icons.add_link),
              label: const Text('Vincular Maceta'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context, CropEntity crop) {
    final profile = crop.profile;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile.name,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              profile.description,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const Divider(height: 24),
            _buildProfileRow(
              Icons.water_drop,
              'Humedad del Suelo',
              '${profile.minSoilMoisture.toStringAsFixed(0)}-${profile.maxSoilMoisture.toStringAsFixed(0)}%',
            ),
            _buildProfileRow(
              Icons.thermostat,
              'Temperatura',
              '${profile.minTemperature.toStringAsFixed(0)}-${profile.maxTemperature.toStringAsFixed(0)}°C',
            ),
            _buildProfileRow(
              Icons.science,
              'pH del Suelo',
              '${profile.minPH.toStringAsFixed(1)}-${profile.maxPH.toStringAsFixed(1)}',
            ),
            _buildProfileRow(
              Icons.wb_sunny,
              'Luz Diaria',
              '${profile.requiredLightHours} horas',
            ),
            _buildProfileRow(
              Icons.lightbulb,
              'Lux Óptimos',
              '${profile.optimalLux} lux',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildControlButton(BuildContext context, CropEntity crop) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ControlScreen(cropId: crop.id),
            ),
          );
        },
        icon: const Icon(Icons.settings_remote),
        label: const Text('Controlar Actuadores'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
