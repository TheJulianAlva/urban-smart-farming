import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urban_smart_farming/core/di/di_container.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/crop_profile.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/profiles_bloc.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/profiles_event.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/profiles_state.dart';
import 'package:urban_smart_farming/features/crops/presentation/widgets/profile_card.dart';

/// Paso 3 del Wizard: Configuración de Perfil
class WizardStep3Profile extends StatefulWidget {
  final CropProfile? initialProfile;
  final bool initialIsExpertMode;
  final Function(CropProfile profile, bool isExpertMode) onDataChanged;

  const WizardStep3Profile({
    super.key,
    this.initialProfile,
    this.initialIsExpertMode = false,
    required this.onDataChanged,
  });

  @override
  State<WizardStep3Profile> createState() => _WizardStep3ProfileState();
}

class _WizardStep3ProfileState extends State<WizardStep3Profile> {
  bool _isExpertMode = false;
  CropProfile? _selectedProfile;

  // BLoC propio para cargar perfiles reales de Supabase (con UUIDs válidos)
  late final ProfilesBloc _profilesBloc;

  // Controladores para modo experto
  late TextEditingController _minMoistureController;
  late TextEditingController _maxMoistureController;
  late TextEditingController _minTempController;
  late TextEditingController _maxTempController;
  late TextEditingController _lightHoursController;
  late TextEditingController _optimalLuxController;

  @override
  void initState() {
    super.initState();
    _isExpertMode = widget.initialIsExpertMode;
    _selectedProfile = widget.initialProfile;

    // Cargar perfiles predefinidos + del usuario desde Supabase
    _profilesBloc = getIt<ProfilesBloc>()..add(const LoadUserProfiles());

    // Inicializar controladores
    _minMoistureController = TextEditingController(
      text: widget.initialProfile?.minSoilMoisture.toString() ?? '50',
    );
    _maxMoistureController = TextEditingController(
      text: widget.initialProfile?.maxSoilMoisture.toString() ?? '70',
    );
    _minTempController = TextEditingController(
      text: widget.initialProfile?.minTemperature.toString() ?? '15',
    );
    _maxTempController = TextEditingController(
      text: widget.initialProfile?.maxTemperature.toString() ?? '25',
    );
    _lightHoursController = TextEditingController(
      text: widget.initialProfile?.requiredLightHours.toString() ?? '8',
    );
    _optimalLuxController = TextEditingController(
      text: widget.initialProfile?.optimalLux.toString() ?? '10000',
    );
  }

  @override
  void dispose() {
    _profilesBloc.close();
    _minMoistureController.dispose();
    _maxMoistureController.dispose();
    _minTempController.dispose();
    _maxTempController.dispose();
    _lightHoursController.dispose();
    _optimalLuxController.dispose();
    super.dispose();
  }

  void _notifyChanges() {
    CropProfile profile;

    if (_isExpertMode) {
      // Crear perfil personalizado desde los campos
      profile = PlantProfile(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Perfil Personalizado',
        description: 'Configuración manual',
        minSoilMoisture: double.tryParse(_minMoistureController.text) ?? 50,
        maxSoilMoisture: double.tryParse(_maxMoistureController.text) ?? 70,
        minTemperature: double.tryParse(_minTempController.text) ?? 15,
        maxTemperature: double.tryParse(_maxTempController.text) ?? 25,
        requiredLightHours: int.tryParse(_lightHoursController.text) ?? 8,
        optimalLux: int.tryParse(_optimalLuxController.text) ?? 10000,
        isPredefined: false,
      );
    } else {
      // Usar perfil seleccionado — el usuario debe elegir uno antes de continuar
      if (_selectedProfile == null) return;
      profile = _selectedProfile!;
    }

    widget.onDataChanged(profile, _isExpertMode);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del paso
          Text(
            'Paso 3: Configuración de Perfil',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Define los parámetros ideales para tu cultivo',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Selector de modo
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                label: Text('Soy Principiante'),
                icon: Icon(Icons.auto_awesome),
              ),
              ButtonSegment(
                value: true,
                label: Text('Soy Experto'),
                icon: Icon(Icons.settings),
              ),
            ],
            selected: {_isExpertMode},
            onSelectionChanged: (Set<bool> selection) {
              setState(() {
                _isExpertMode = selection.first;
                _notifyChanges();
              });
            },
          ),
          const SizedBox(height: 32),

          // Contenido según modo
          if (!_isExpertMode) _buildBeginnerMode() else _buildExpertMode(),
        ],
      ),
    );
  }

  Widget _buildBeginnerMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona un Perfil Predefinido',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),

        // Perfiles reales cargados desde Supabase (UUIDs válidos)
        BlocBuilder<ProfilesBloc, ProfilesState>(
          bloc: _profilesBloc,
          builder: (context, state) {
            if (state is ProfilesLoading || state is ProfilesInitial) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (state is ProfilesError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error al cargar perfiles: ${state.message}',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
              );
            }

            if (state is ProfilesLoaded) {
              final profiles = state.userProfiles;
              if (profiles.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No hay perfiles disponibles.'),
                );
              }
              return Column(
                children: profiles.map((profile) {
                  return ProfileCard(
                    profile: profile,
                    isSelected: _selectedProfile?.id == profile.id,
                    onTap: () {
                      setState(() {
                        _selectedProfile = profile;
                        _notifyChanges();
                      });
                    },
                  );
                }).toList(),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildExpertMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuración Manual de Parámetros',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),

        // Humedad
        Text(
          'Humedad del Suelo (%)',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minMoistureController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Mínimo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixText: '%',
                ),
                onChanged: (_) => _notifyChanges(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _maxMoistureController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Máximo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixText: '%',
                ),
                onChanged: (_) => _notifyChanges(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Temperatura
        Text('Temperatura (°C)', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minTempController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Mínima',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixText: '°C',
                ),
                onChanged: (_) => _notifyChanges(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _maxTempController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Máxima',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixText: '°C',
                ),
                onChanged: (_) => _notifyChanges(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Horas de luz
        Text(
          'Horas de Luz Diarias',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _lightHoursController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Horas',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixText: 'horas',
            helperText: 'Cantidad de horas de luz requeridas por día',
          ),
          onChanged: (_) => _notifyChanges(),
        ),
        const SizedBox(height: 24),

        // Lux óptimos
        Text(
          'Iluminación Óptima',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _optimalLuxController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Lux',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixText: 'lux',
            helperText: 'Intensidad de luz óptima (ej: 10000 lux)',
          ),
          onChanged: (_) => _notifyChanges(),
        ),
      ],
    );
  }
}
