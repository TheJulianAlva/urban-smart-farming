import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:urban_smart_farming/core/routing/app_router.dart';
import 'package:urban_smart_farming/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:urban_smart_farming/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:urban_smart_farming/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:urban_smart_farming/features/dashboard/presentation/widgets/metric_card.dart';
import 'package:urban_smart_farming/core/theme/app_theme.dart';

/// Pantalla principal del Dashboard (S-02)
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar datos al iniciar
    context.read<DashboardBloc>().add(LoadDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Cultivo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(AppRouter.settings),
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DashboardBloc>().add(LoadDashboardData());
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is DashboardLoaded) {
            final sensorData = state.sensorData;
            final actuators = state.actuators;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(RefreshDashboardData());
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Última actualización
                    Center(
                      child: Text(
                        'Última actualización: ${_formatTime(sensorData.timestamp)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Título de métricas
                    Text(
                      'Métricas Actuales',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),

                    // Grid de métricas
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                      children: [
                        MetricCard(
                          title: 'Temperatura',
                          value: sensorData.temperature,
                          unit: '°C',
                          icon: Icons.thermostat,
                          status: sensorData.temperatureStatus,
                        ),
                        MetricCard(
                          title: 'Humedad',
                          value: sensorData.humidity,
                          unit: '%',
                          icon: Icons.water_drop,
                          status: sensorData.humidityStatus,
                        ),
                        MetricCard(
                          title: 'Luz',
                          value: sensorData.lightLevel,
                          unit: 'Lux',
                          icon: Icons.wb_sunny,
                          status: sensorData.lightStatus,
                        ),
                        MetricCard(
                          title: 'pH',
                          value: sensorData.ph,
                          unit: '',
                          icon: Icons.science,
                          status: sensorData.phStatus,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Título actuadores
                    Text(
                      'Estado de Actuadores',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),

                    // Lista de actuadores
                    ...actuators
                        .map(
                          (actuator) => Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Icon(
                                _getActuatorIcon(actuator.type),
                                color:
                                    actuator.isOn
                                        ? AppTheme.primaryGreen
                                        : Colors.grey,
                              ),
                              title: Text(actuator.name),
                              trailing: Chip(
                                label: Text(
                                  actuator.isOn ? 'ON' : 'OFF',
                                  style: TextStyle(
                                    color:
                                        actuator.isOn
                                            ? AppTheme.primaryGreen
                                            : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor:
                                    actuator.isOn
                                        ? AppTheme.primaryGreen.withValues(
                                          alpha: 0.2,
                                        )
                                        : Colors.grey.withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('Iniciando...'));
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  IconData _getActuatorIcon(type) {
    switch (type.toString()) {
      case 'ActuatorType.pump':
        return Icons.water;
      case 'ActuatorType.light':
        return Icons.lightbulb;
      case 'ActuatorType.fan':
        return Icons.air;
      default:
        return Icons.device_unknown;
    }
  }
}
