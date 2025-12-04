import 'package:flutter/material.dart';

/// Pantalla de control para un cultivo específico (S-03)
/// Placeholder
class ControlScreen extends StatelessWidget {
  final String cropId;

  const ControlScreen({required this.cropId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Control')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestión de Cultivo',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Cultivo ID: $cropId',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            Text(
              'Control Manual',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Bomba de Riego'),
                    subtitle: const Text('Control manual de irrigación'),
                    value: false,
                    onChanged: (value) {},
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Luz LED'),
                    subtitle: const Text('Iluminación suplementaria'),
                    value: true,
                    onChanged: (value) {},
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Ventilación'),
                    subtitle: const Text('Control de flujo de aire'),
                    value: false,
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
