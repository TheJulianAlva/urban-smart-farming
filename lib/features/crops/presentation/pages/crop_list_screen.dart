import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:urban_smart_farming/core/di/di_container.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/crops_bloc.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/crops_event.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/crops_state.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/crop_entity.dart';
import 'package:urban_smart_farming/features/crops/presentation/widgets/global_status_card.dart';
import 'package:urban_smart_farming/features/crops/presentation/widgets/status_badge.dart';

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
              const Text('Hola, Usuario', style: TextStyle(fontSize: 20)),
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
                        '3',
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

                    // Grid de cultivos
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return _CropCard(crop: state.crops[index]);
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
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Navegar al detalle del cultivo
          context.push('/crops/${crop.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono de cultivo con badges
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.eco,
                      color: Theme.of(context).colorScheme.primary,
                      size: 30,
                    ),
                  ),
                  // Mostrar badges según estado (mockup)
                  ..._getCropStatusBadges(crop),
                ],
              ),
              const SizedBox(height: 12),

              // Nombre del cultivo
              Text(
                crop.name,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),

              // Ubicación
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      crop.location,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Última actualización
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    lastUpdateText,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
}
