import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urban_smart_farming/features/control/presentation/bloc/control_bloc.dart';
import 'package:urban_smart_farming/features/control/presentation/bloc/control_event.dart';
import 'package:urban_smart_farming/features/control/presentation/bloc/control_state.dart';

/// Pantalla de control para un cultivo específico (S-03)
/// Permite control manual/automático de actuadores
class ControlScreen extends StatelessWidget {
  final String cropId;

  const ControlScreen({required this.cropId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ControlBloc()..add(LoadControlData(cropId)),
      child: Scaffold(
        body: BlocConsumer<ControlBloc, ControlState>(
          listener: (context, state) {
            if (state is ControlError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ControlLoading || state is ControlInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ControlUpdating) {
              return Stack(
                children: [
                  _buildControlContent(context, state),
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: Center(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(state.action),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            if (state is ControlLoaded) {
              return _buildControlContent(context, state);
            }

            return const Center(child: Text('Error inesperado'));
          },
        ),
      ),
    );
  }

  Widget _buildControlContent(BuildContext context, dynamic state) {
    final isLoaded = state is ControlLoaded;
    final isAutomaticMode = isLoaded ? state.isAutomaticMode : true;
    final isPumpOn = isLoaded ? state.isPumpOn : false;
    final isLightOn = isLoaded ? state.isLightOn : false;
    final lightIntensity = isLoaded ? state.lightIntensity : 0;
    final isFanOn = isLoaded ? state.isFanOn : false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            'Control del Cultivo',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'ID: $cropId',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Modo de Operación
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isAutomaticMode ? Icons.auto_mode : Icons.touch_app,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Modo de Operación',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Modo Automático'),
                    subtitle: Text(
                      isAutomaticMode
                          ? 'El sistema gestiona el riego y la iluminación según el perfil'
                          : 'Control manual activado - Gestiona los actuadores manualmente',
                    ),
                    value: isAutomaticMode,
                    onChanged:
                        isLoaded
                            ? (value) {
                              context.read<ControlBloc>().add(
                                ToggleAutomaticMode(value),
                              );
                            }
                            : null,
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Controles Manuales
          Text(
            'Controles Manuales',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (isAutomaticMode)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Desactiva el modo automático para controlar manualmente',
                      style: TextStyle(fontSize: 13, color: Colors.orange[900]),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Control de Riego
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.water_drop,
                        color: isPumpOn ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bomba de Riego',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              isPumpOn ? 'Activa - Regando' : 'Inactiva',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: isPumpOn ? Colors.blue : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed:
                            (!isAutomaticMode && isLoaded)
                                ? () {
                                  context.read<ControlBloc>().add(
                                    TogglePump(!isPumpOn),
                                  );
                                }
                                : null,
                        icon: Icon(isPumpOn ? Icons.stop : Icons.play_arrow),
                        label: Text(isPumpOn ? 'Detener' : 'Regar Ahora'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPumpOn ? Colors.red : Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Control de Iluminación
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: isLightOn ? Colors.amber : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Iluminación LED',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              isLightOn
                                  ? 'Encendida - $lightIntensity%'
                                  : 'Apagada',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: isLightOn ? Colors.amber : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isLightOn,
                        onChanged:
                            (!isAutomaticMode && isLoaded)
                                ? (value) {
                                  context.read<ControlBloc>().add(
                                    ToggleLight(value),
                                  );
                                }
                                : null,
                      ),
                    ],
                  ),
                  if (!isAutomaticMode && isLightOn) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Intensidad: $lightIntensity%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Slider(
                      value: lightIntensity.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 10,
                      label: '$lightIntensity%',
                      onChanged:
                          isLoaded
                              ? (value) {
                                context.read<ControlBloc>().add(
                                  SetLightIntensity(value.toInt()),
                                );
                              }
                              : null,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Control de Ventilación
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.air, color: isFanOn ? Colors.teal : Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ventilación',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          isFanOn ? 'Activa' : 'Inactiva',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: isFanOn ? Colors.teal : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isFanOn,
                    onChanged:
                        (!isAutomaticMode && isLoaded)
                            ? (value) {
                              context.read<ControlBloc>().add(ToggleFan(value));
                            }
                            : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
