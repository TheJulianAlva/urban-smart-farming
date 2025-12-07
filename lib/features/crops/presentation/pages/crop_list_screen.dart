import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:urban_smart_farming/core/di/di_container.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/crops_bloc.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/crops_event.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/crops_state.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/crop_entity.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/sensor.dart';
import 'package:urban_smart_farming/features/crops/presentation/widgets/global_status_card.dart';
import 'package:urban_smart_farming/features/crops/presentation/widgets/status_badge.dart';
import 'package:urban_smart_farming/features/crops/presentation/widgets/sensor_gauge.dart';

/// Pantalla principal "Mi Jardín" - Dashboard global de cultivos
class CropListScreen extends StatelessWidget {
  const CropListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CropsBloc>()..add(LoadCrops()),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Text('Mi Jardín', style: TextStyle(fontSize: 26)),
              const Spacer(),
              // Badge de notificaciones con indicador
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      // TODO: Navigate to notifications/alerts
                    },
                  ),
                  // Badge contador (mockup - siempre muestra 3)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: const Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          automaticallyImplyLeading: false,
        ),
        body: BlocBuilder<CropsBloc, CropsState>(
          builder: (context, state) {
            if (state is CropsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CropsError) {
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
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          () => context.read<CropsBloc>().add(RefreshCrops()),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is CropsLoaded) {
              if (state.crops.isEmpty) {
                return _buildEmptyState(context);
              }

              // Calcular estado global (mockup)
              final statusData = _calculateGlobalStatus(state.crops);

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<CropsBloc>().add(RefreshCrops());
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: CustomScrollView(
                  slivers: [
                    // Resumen de Estado Global
                    SliverToBoxAdapter(
                      child: GlobalStatusCard(
                        totalCrops: state.crops.length,
                        cropsNeedingAttention: statusData['needsAttention']!,
                        criticalCrops: statusData['critical']!,
                      ),
                    ),

                    // Lista de cultivos
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _CropCard(crop: state.crops[index]),
                          );
                        }, childCount: state.crops.length),
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/create-crop'),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco,
            size: 100,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No tienes cultivos registrados',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer cultivo para comenzar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/create-crop'),
            icon: const Icon(Icons.add),
            label: const Text('Crear Cultivo'),
          ),
        ],
      ),
    );
  }

  /// Calcula el estado global de los cultivos (mockup basado en ID)
  Map<String, int> _calculateGlobalStatus(List<CropEntity> crops) {
    int needsAttention = 0;
    int critical = 0;

    for (var crop in crops) {
      // Mockup: usar hash del ID para determinar estado
      final hash = crop.id.hashCode % 100;

      if (hash < 15) {
        critical++; // 15% críticos
      } else if (hash < 40) {
        needsAttention++; // 25% necesita atención
      }
      // El resto está bien (60%)
    }

    return {'needsAttention': needsAttention, 'critical': critical};
  }
}

class _CropCard extends StatelessWidget {
  final CropEntity crop;

  const _CropCard({required this.crop});

  @override
  Widget build(BuildContext context) {
    final lastUpdateText =
        crop.lastUpdate != null
            ? _getRelativeTime(crop.lastUpdate!)
            : 'Sin datos';

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          context.push('/dashboard/${crop.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar circular del cultivo
              CircleAvatar(
                radius: 36,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.eco,
                  size: 36,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),

              // Información del cultivo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    Text(
                      crop.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Tipo de planta
                    Text(
                      crop.plantType,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Indicadores de sensores (solo si tiene hardware)
                    if (crop.hasHardware) ...[
                      _buildSensorDots(context, crop),
                      const SizedBox(height: 6),
                    ],

                    // Ubicación y tiempo
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            crop.location,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lastUpdateText,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Icono de navegación
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorDots(BuildContext context, CropEntity crop) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDotIndicator(
          context,
          crop.getSensor(SensorType.temperature),
          crop.profile.isTemperatureOptimal,
          Icons.thermostat,
        ),
        const SizedBox(width: 6),
        _buildDotIndicator(
          context,
          crop.getSensor(SensorType.soilMoisture),
          crop.profile.isSoilMoistureOptimal,
          Icons.water_drop,
        ),
        const SizedBox(width: 6),
        _buildDotIndicator(
          context,
          crop.getSensor(SensorType.ph),
          crop.profile.isPHOptimal,
          Icons.science,
        ),
        const SizedBox(width: 6),
        _buildDotIndicator(
          context,
          crop.getSensor(SensorType.light),
          (value) => crop.profile.isLightOptimal(value.toInt()),
          Icons.wb_sunny,
        ),
      ],
    );
  }

  Widget _buildDotIndicator(
    BuildContext context,
    Sensor? sensor,
    Function(double) isOptimal,
    IconData icon,
  ) {
    Color dotColor;

    if (sensor == null || sensor.currentValue == null) {
      dotColor = Colors.grey[400]!;
    } else {
      final status = _getSensorStatus(sensor, isOptimal);
      dotColor = _getStatusColor(status);
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: dotColor.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: dotColor, width: 2),
      ),
      child: Icon(icon, size: 16, color: dotColor),
    );
  }

  SensorStatus _getSensorStatus(Sensor sensor, Function(double) isOptimal) {
    final value = sensor.currentValue!;

    if (isOptimal(value)) {
      return SensorStatus.optimal;
    }

    // Simplificado: si no está en óptimo, warning
    // En producción usaríamos lógica más completa
    return SensorStatus.warning;
  }

  Color _getStatusColor(SensorStatus status) {
    switch (status) {
      case SensorStatus.optimal:
        return Colors.green[600]!;
      case SensorStatus.warning:
        return Colors.orange[600]!;
      case SensorStatus.critical:
        return Colors.red[600]!;
      case SensorStatus.unknown:
        return Colors.grey[400]!;
    }
  }
}

String _getRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 1) {
    return 'Ahora';
  } else if (difference.inMinutes < 60) {
    return 'Hace ${difference.inMinutes} min';
  } else if (difference.inHours < 24) {
    return 'Hace ${difference.inHours}h';
  } else {
    return 'Hace ${difference.inDays}d';
  }
}

/// Genera badges según el estado del cultivo (mockup)
List<Widget> _getCropStatusBadges(CropEntity crop) {
  final badges = <Widget>[];
  final hash = crop.id.hashCode % 100;

  if (hash < 15) {
    // Crítico - mostrar badge de advertencia
    badges.add(
      const Positioned(
        top: -4,
        right: -4,
        child: StatusBadge(type: BadgeType.critical, size: 20),
      ),
    );
  } else if (hash < 30) {
    // Necesita agua
    badges.add(
      const Positioned(
        top: -4,
        right: -4,
        child: StatusBadge(type: BadgeType.needsWater, size: 20),
      ),
    );
  } else if (hash < 40) {
    // Necesita luz
    badges.add(
      const Positioned(
        top: -4,
        right: -4,
        child: StatusBadge(type: BadgeType.needsLight, size: 20),
      ),
    );
  }

  return badges;
}
