import 'package:flutter/material.dart';

/// Paso 1 del Wizard: Datos Básicos del Cultivo
class WizardStep1BasicInfo extends StatefulWidget {
  final String? initialName;
  final String? initialLocation;
  final Function(String name, String location) onDataChanged;

  const WizardStep1BasicInfo({
    super.key,
    this.initialName,
    this.initialLocation,
    required this.onDataChanged,
  });

  @override
  State<WizardStep1BasicInfo> createState() => _WizardStep1BasicInfoState();
}

class _WizardStep1BasicInfoState extends State<WizardStep1BasicInfo> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _locationController = TextEditingController(
      text: widget.initialLocation ?? '',
    );

    // Notificar cambios
    _nameController.addListener(_notifyChanges);
    _locationController.addListener(_notifyChanges);
  }

  void _notifyChanges() {
    widget.onDataChanged(_nameController.text, _locationController.text);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
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
            'Paso 1: Datos Básicos',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Ingresa la información básica de tu cultivo',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Campo: Nombre del cultivo
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nombre del Cultivo',
              hintText: 'Ej. Tomates Cherry',
              prefixIcon: const Icon(Icons.grass),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 24),

          // Campo: Ubicación
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Ubicación',
              hintText: 'Ej. Terraza, Cocina, Jardín',
              prefixIcon: const Icon(Icons.location_on),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 32),

          // Selector de Icono (Opcional - simplificado)
          Text(
            'Icono del Cultivo',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Se usará el icono predeterminado 🌱',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.eco,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Icono predeterminado para todos los cultivos',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
