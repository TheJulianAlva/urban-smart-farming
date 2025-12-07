import 'package:flutter/material.dart';
import 'dart:async';
import 'package:urban_smart_farming/features/crops/domain/entities/pot.dart';
import 'package:urban_smart_farming/features/crops/data/models/mock_pot_factory.dart';
import 'dart:math';

/// Paso 2 del Wizard: Vincular Maceta Inteligente
class WizardStep2Hardware extends StatefulWidget {
  final Pot? initialPot;
  final Function(Pot? pot, bool skipHardware) onDataChanged;

  const WizardStep2Hardware({
    super.key,
    this.initialPot,
    required this.onDataChanged,
  });

  @override
  State<WizardStep2Hardware> createState() => _WizardStep2HardwareState();
}

class _WizardStep2HardwareState extends State<WizardStep2Hardware> {
  bool _wantsToLink = false;
  bool _isScanning = false;
  List<Pot> _discoveredPots = [];
  Pot? _selectedPot;

  @override
  void initState() {
    super.initState();
    _selectedPot = widget.initialPot;
    _wantsToLink = widget.initialPot != null;
  }

  Future<void> _scanForPots() async {
    setState(() {
      _isScanning = true;
      _discoveredPots = [];
    });

    // Simular búsqueda de dispositivos (2 segundos)
    await Future.delayed(const Duration(seconds: 2));

    // Generar 1-3 pots aleatorios para simular detección
    final random = Random();
    final shouldFind =
        random.nextDouble() > 0.1; // 90% probabilidad de encontrar

    if (shouldFind && mounted) {
      final count = random.nextInt(3) + 1; // 1-3 dispositivos
      final pots = List.generate(count, (i) {
        return MockPotFactory.createMockPot(
          id: 'pot-scan-${DateTime.now().millisecondsSinceEpoch}-$i',
          cropId: 'temp',
          hardwareName:
              'ESP32-${random.nextInt(999999).toString().padLeft(6, '0')}',
        );
      });

      setState(() {
        _discoveredPots = pots;
        _isScanning = false;
      });
    } else if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  void _selectPot(Pot pot) {
    setState(() {
      _selectedPot = pot;
    });
    widget.onDataChanged(pot, false);
  }

  void _skipHardware() {
    setState(() {
      _wantsToLink = false;
      _selectedPot = null;
      _discoveredPots = [];
    });
    widget.onDataChanged(null, true);
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
            'Paso 2: Vincular Maceta Inteligente',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '¿Tienes una maceta inteligente para este cultivo?',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Beneficios de vincular
          _buildBenefitsCard(),
          const SizedBox(height: 24),

          // Radio buttons para seleccionar
          _buildSelectionRadios(),
          const SizedBox(height: 24),

          // Contenido según selección
          if (_wantsToLink) ...[
            if (!_isScanning && _discoveredPots.isEmpty && _selectedPot == null)
              _buildScanButton(),

            if (_isScanning) _buildScanningState(),

            if (!_isScanning &&
                _discoveredPots.isNotEmpty &&
                _selectedPot == null)
              _buildDevicesList(),

            if (!_isScanning && _discoveredPots.isEmpty && _selectedPot == null)
              _buildNoDevicesFound(),

            if (_selectedPot != null) _buildSelectedDevice(),
          ] else ...[
            _buildSkipMessage(),
          ],
        ],
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(
                'Beneficios de vincular',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildBenefitRow('Monitorear temperatura, humedad, pH y luz'),
          _buildBenefitRow('Controlar riego y luz LED automáticamente'),
          _buildBenefitRow('Recibir alertas cuando algo está mal'),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.green[900]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionRadios() {
    return Column(
      children: [
        RadioListTile<bool>(
          title: const Text('Sí, quiero vincular ahora'),
          subtitle: const Text('Buscar y conectar mi maceta inteligente'),
          value: true,
          groupValue: _wantsToLink,
          onChanged: (value) {
            setState(() {
              _wantsToLink = value!;
              if (!value) {
                _skipHardware();
              }
            });
          },
        ),
        RadioListTile<bool>(
          title: const Text('No, vincular después'),
          subtitle: const Text('Continuar sin hardware (modo mockup)'),
          value: false,
          groupValue: _wantsToLink,
          onChanged: (value) {
            setState(() {
              _wantsToLink = value!;
              if (!value) {
                _skipHardware();
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildScanButton() {
    return Column(
      children: [
        // Instrucciones
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Asegúrate de que tu maceta esté:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInstructionRow('Encendida'),
              _buildInstructionRow('En modo de vinculación (LED parpadeando)'),
              _buildInstructionRow('Cerca de tu teléfono (< 5 metros)'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Botón de escanear
        ElevatedButton.icon(
          onPressed: _scanForPots,
          icon: const Icon(Icons.search),
          label: const Text('Buscar Dispositivos'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.check, size: 16, color: Colors.blue[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.blue[900]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningState() {
    return Center(
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Buscando dispositivos...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Esto puede tomar unos segundos',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dispositivos encontrados (${_discoveredPots.length})',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        ..._discoveredPots.map((pot) => _buildDeviceCard(pot)),

        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _scanForPots,
          icon: const Icon(Icons.refresh),
          label: const Text('Buscar de Nuevo'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceCard(Pot pot) {
    final signalStrength = pot.isConnected ? 'Fuerte' : 'Media';
    final signalIcon =
        pot.isConnected
            ? Icons.signal_wifi_4_bar
            : Icons.signal_wifi_statusbar_4_bar;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.sensors, color: Colors.green[600], size: 32),
        title: Text(
          pot.name ?? pot.hardwareId,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('ID: ${pot.hardwareId}'),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(signalIcon, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Señal: $signalStrength',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 12),
                Icon(Icons.sensors, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${pot.sensors.length}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _selectPot(pot),
          child: const Text('Seleccionar'),
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildNoDevicesFound() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.sensors_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No se encontraron dispositivos',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '¿Tu maceta está encendida?\nRevisa que el LED esté parpadeando.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _scanForPots,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextButton(
                  onPressed: _skipHardware,
                  child: const Text('Continuar sin hardware'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDevice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[700], size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dispositivo Vinculado',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedPot!.name ?? _selectedPot!.hardwareId,
                      style: TextStyle(color: Colors.green[800]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'Sensores detectados',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              _selectedPot!.sensors.map((sensor) {
                return Chip(
                  avatar: Icon(_getSensorIcon(sensor.type), size: 16),
                  label: Text(sensor.name),
                );
              }).toList(),
        ),

        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _selectedPot = null;
            });
          },
          icon: const Icon(Icons.change_circle),
          label: const Text('Cambiar Dispositivo'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  Widget _buildSkipMessage() {
    return Container(
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
              'Podrás vincular una maceta más tarde desde el dashboard del cultivo.',
              style: TextStyle(fontSize: 13, color: Colors.blue[900]),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSensorIcon(sensorType) {
    // Simple type check since we can't import SensorType enum here
    final typeStr = sensorType.toString().split('.').last;
    switch (typeStr) {
      case 'temperature':
        return Icons.thermostat;
      case 'soilMoisture':
        return Icons.water_drop;
      case 'ph':
        return Icons.science;
      case 'light':
        return Icons.wb_sunny;
      default:
        return Icons.sensors;
    }
  }
}
