import 'package:flutter/material.dart';

/// Pantalla de Historial y Analíticas (S-04)
/// Placeholder simple para el mockup inicial
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedSensor = 'Temperatura';
  String _selectedRange = 'Semana';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial y Analíticas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtros superiores
            Text('Filtros', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),

            // Selector de sensor
            DropdownButtonFormField<String>(
              value: _selectedSensor,
              decoration: const InputDecoration(
                labelText: 'Tipo de Sensor',
                prefixIcon: Icon(Icons.sensors),
              ),
              items:
                  ['Temperatura', 'Humedad', 'Luz', 'pH'].map((sensor) {
                    return DropdownMenuItem(value: sensor, child: Text(sensor));
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedSensor = value);
                }
              },
            ),

            const SizedBox(height: 16),

            // Selector de rango
            Row(
              children:
                  ['Hoy', 'Semana', 'Mes'].map((range) {
                    final isSelected = _selectedRange == range;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(range),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedRange = range);
                          }
                        },
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 32),

            // Área de gráfica (placeholder)
            Text(
              'Gráfica de Tendencia',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.show_chart,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gráfico de $_selectedSensor',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rango: $_selectedRange',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Resumen estadístico
            Text(
              'Resumen Estadístico',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.arrow_upward,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Máximo',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '28.5°C',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.analytics, color: Colors.orange),
                          const SizedBox(height: 8),
                          Text(
                            'Promedio',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '24.2°C',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.arrow_downward, color: Colors.blue),
                          const SizedBox(height: 8),
                          Text(
                            'Mínimo',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '20.1°C',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
