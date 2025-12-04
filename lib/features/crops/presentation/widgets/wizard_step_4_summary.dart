import 'package:flutter/material.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/crop_profile.dart';

/// Paso 4 del Wizard: Resumen y Confirmación
class WizardStep4Summary extends StatelessWidget {
  final String name;
  final String location;
  final String? hardwareId;
  final CropProfile profile;

  const WizardStep4Summary({
    super.key,
    required this.name,
    required this.location,
    this.hardwareId,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del paso
          Text(
            'Paso 4: Resumen',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Revisa la información antes de crear tu cultivo',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Icono y nombre del cultivo
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.eco,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name.isEmpty ? 'Sin nombre' : name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Sección: Información Básica
          _buildSectionHeader(context, 'Información Básica'),
          _buildInfoCard(context, [
            _buildInfoRow(Icons.location_on, 'Ubicación', location),
            _buildInfoRow(
              Icons.device_hub,
              'Hardware',
              _getHardwareName(hardwareId),
            ),
          ]),
          const SizedBox(height: 24),

          // Sección: Perfil de Cultivo
          _buildSectionHeader(context, 'Perfil de Cultivo'),
          _buildInfoCard(context, [
            _buildInfoRow(Icons.grass, 'Perfil', profile.name),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                profile.description,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
              ),
            ),
            const Divider(),
            _buildInfoRow(
              Icons.water_drop,
              'Humedad',
              '${profile.minHumidity}% - ${profile.maxHumidity}%',
            ),
            _buildInfoRow(
              Icons.thermostat,
              'Temperatura',
              '${profile.minTemperature}°C - ${profile.maxTemperature}°C',
            ),
            _buildInfoRow(
              Icons.wb_sunny,
              'Luz',
              '${profile.requiredLightHours} horas/día',
            ),
          ]),
          const SizedBox(height: 32),

          // Mensaje de confirmación
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Todo listo para crear tu cultivo. Presiona "Crear Cultivo" para finalizar.',
                    style: TextStyle(fontSize: 13, color: Colors.green[900]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _getHardwareName(String? hardwareId) {
    if (hardwareId == null || hardwareId == 'none') {
      return 'Sin Hardware (Mockup)';
    }
    return 'Sensor Node (ID: $hardwareId)';
  }
}
