import 'package:flutter/material.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/crop_profile.dart';

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

  // Controladores para modo experto
  late TextEditingController _minHumidityController;
  late TextEditingController _maxHumidityController;
  late TextEditingController _minTempController;
  late TextEditingController _maxTempController;
  late TextEditingController _lightHoursController;

  @override
  void initState() {
    super.initState();
    _isExpertMode = widget.initialIsExpertMode;
    _selectedProfile = widget.initialProfile;

    // Inicializar controladores
    _minHumidityController = TextEditingController(
      text: widget.initialProfile?.minHumidity.toString() ?? '50',
    );
    _maxHumidityController = TextEditingController(
      text: widget.initialProfile?.maxHumidity.toString() ?? '70',
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
  }

  @override
  void dispose() {
    _minHumidityController.dispose();
    _maxHumidityController.dispose();
    _minTempController.dispose();
    _maxTempController.dispose();
    _lightHoursController.dispose();
    super.dispose();
  }

  void _notifyChanges() {
    CropProfile profile;

    if (_isExpertMode) {
      // Crear perfil personalizado desde los campos
      profile = CropProfile(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Perfil Personalizado',
        description: 'Configuración manual',
        minHumidity: double.tryParse(_minHumidityController.text) ?? 50,
        maxHumidity: double.tryParse(_maxHumidityController.text) ?? 70,
        minTemperature: double.tryParse(_minTempController.text) ?? 15,
        maxTemperature: double.tryParse(_maxTempController.text) ?? 25,
        requiredLightHours: int.tryParse(_lightHoursController.text) ?? 8,
        isPredefined: false,
      );
    } else {
      // Usar perfil seleccionado o default
      profile = _selectedProfile ?? PredefinedProfiles.profiles.first;
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

        // Lista de perfiles predefinidos
        ...PredefinedProfiles.profiles.map((profile) {
          final isSelected = _selectedProfile?.id == profile.id;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
            child: ListTile(
              leading: Icon(
                Icons.eco,
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.green,
              ),
              title: Text(
                profile.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(profile.description),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: Text(
                          '💧 ${profile.minHumidity}-${profile.maxHumidity}%',
                          style: const TextStyle(fontSize: 11),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      Chip(
                        label: Text(
                          '🌡️ ${profile.minTemperature}-${profile.maxTemperature}°C',
                          style: const TextStyle(fontSize: 11),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      Chip(
                        label: Text(
                          '☀️ ${profile.requiredLightHours}h',
                          style: const TextStyle(fontSize: 11),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ],
              ),
              trailing:
                  isSelected
                      ? Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      )
                      : null,
              isThreeLine: true,
              onTap: () {
                setState(() {
                  _selectedProfile = profile;
                  _notifyChanges();
                });
              },
            ),
          );
        }),
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
                controller: _minHumidityController,
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
                controller: _maxHumidityController,
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
      ],
    );
  }
}
