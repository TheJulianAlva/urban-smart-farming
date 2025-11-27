import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:urban_smart_farming/core/di/di_container.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/crops_bloc.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/crops_event.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/crops_state.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/crop_entity.dart';

/// Pantalla principal de lista de cultivos
class CropListScreen extends StatelessWidget {
  const CropListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CropsBloc>()..add(LoadCrops()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Cultivos'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.push('/settings'),
            ),
          ],
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

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<CropsBloc>().add(RefreshCrops());
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: state.crops.length,
                  itemBuilder: (context, index) {
                    return _CropCard(crop: state.crops[index]);
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: BlocBuilder<CropsBloc, CropsState>(
          builder: (context, state) {
            // Deshabilitar si se alcanzó el límite
            final canAdd = state is CropsLoaded && state.crops.length < 10;

            return FloatingActionButton(
              onPressed: canAdd ? () => _showCreateCropDialog(context) : null,
              child: const Icon(Icons.add),
            );
          },
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
            onPressed: () => _showCreateCropDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Crear Cultivo'),
          ),
        ],
      ),
    );
  }

  void _showCreateCropDialog(BuildContext context) {
    final nameController = TextEditingController();
    final plantTypeController = TextEditingController();
    final locationController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Nuevo Cultivo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Ej: Tomates del Balcón',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: plantTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Planta',
                    hintText: 'Ej: Tomate Cherry',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Ubicación',
                    hintText: 'Ej: Balcón Norte',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      locationController.text.isNotEmpty) {
                    context.read<CropsBloc>().add(
                      CreateCropRequested(
                        name: nameController.text,
                        plantType:
                            plantTypeController.text.isEmpty
                                ? 'Sin especificar'
                                : plantTypeController.text,
                        location: locationController.text,
                      ),
                    );
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: const Text('Crear'),
              ),
            ],
          ),
    );
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
              // Icono de cultivo
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
                  size: 28,
                ),
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
}
