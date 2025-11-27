import 'package:flutter/material.dart';

/// Pantalla de Control y Automatización (S-03)
/// Placeholder simple para el mockup inicial
class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Control y Automatización')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección de control manual
          Text(
            'Control Manual',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Bomba de Riego'),
            subtitle: const Text('Sistema de riego automático'),
            secondary: const Icon(Icons.water),
            value: false,
            onChanged: (value) {},
          ),

          SwitchListTile(
            title: const Text('Luz LED'),
            subtitle: const Text('Iluminación artificial'),
            secondary: const Icon(Icons.lightbulb),
            value: true,
            onChanged: (value) {},
          ),

          SwitchListTile(
            title: const Text('Ventilación'),
            subtitle: const Text('Sistema de ventilación'),
            secondary: const Icon(Icons.air),
            value: false,
            onChanged: (value) {},
          ),

          const SizedBox(height: 32),

          // Sección de reglas automáticas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reglas Automáticas',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funcionalidad disponible próximamente'),
                    ),
                  );
                },
                tooltip: 'Añadir regla',
              ),
            ],
          ),
          const SizedBox(height: 16),

          Card(
            child: ListTile(
              leading: const Icon(Icons.rule),
              title: const Text('Si Humedad < 50%'),
              subtitle: const Text('Entonces: Activar riego 5 min'),
              trailing: Switch(value: true, onChanged: (value) {}),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.rule),
              title: const Text('Si Luz < 400 Lux'),
              subtitle: const Text('Entonces: Encender LED'),
              trailing: Switch(value: true, onChanged: (value) {}),
            ),
          ),
        ],
      ),
    );
  }
}
