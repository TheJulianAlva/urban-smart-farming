import 'package:flutter/material.dart';

/// Paso 2 del Wizard: Vincular Hardware
class WizardStep2Hardware extends StatefulWidget {
  final String? initialHardwareId;
  final Function(String? hardwareId) onDataChanged;

  const WizardStep2Hardware({
    super.key,
    this.initialHardwareId,
    required this.onDataChanged,
  });

  @override
  State<WizardStep2Hardware> createState() => _WizardStep2HardwareState();
}

class _WizardStep2HardwareState extends State<WizardStep2Hardware> {
  String? _selectedHardwareId;

  // Lista de dispositivos disponibles (mockup)
  final List<Map<String, String>> _availableDevices = [
    {'id': 'none', 'name': 'Sin Hardware (Mockup)', 'status': 'Disponible'},
    {'id': 'device_1', 'name': 'Sensor Node #1', 'status': 'Disponible'},
    {'id': 'device_2', 'name': 'Sensor Node #2', 'status': 'Disponible'},
    {'id': 'device_3', 'name': 'Sensor Node #3', 'status': 'En uso'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedHardwareId = widget.initialHardwareId ?? 'none';
  }

  void _selectDevice(String? deviceId) {
    setState(() {
      _selectedHardwareId = deviceId;
    });
    widget.onDataChanged(deviceId);
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
            'Paso 2: Vincular Hardware',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona el dispositivo sensor para este cultivo',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Lista de dispositivos
          ..._availableDevices.map((device) {
            final isAvailable = device['status'] == 'Disponible';
            final isSelected = _selectedHardwareId == device['id'];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
              child: ListTile(
                enabled: isAvailable,
                leading: Icon(
                  Icons.device_hub,
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.primary
                          : (isAvailable ? Colors.green : Colors.grey),
                ),
                title: Text(
                  device['name']!,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(device['status']!),
                trailing:
                    isSelected
                        ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                        : null,
                onTap: isAvailable ? () => _selectDevice(device['id']) : null,
              ),
            );
          }),

          const SizedBox(height: 24),

          // Botón de escanear (placeholder)
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Función de escaneo disponible en versión completa',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Escanear Nuevo Dispositivo'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),

          const SizedBox(height: 16),

          // Información adicional
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Puedes continuar sin hardware para probar la aplicación en modo mockup.',
                    style: TextStyle(fontSize: 13, color: Colors.blue[900]),
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
