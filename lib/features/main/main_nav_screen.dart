import 'package:flutter/material.dart';
import 'package:urban_smart_farming/features/crops/presentation/pages/crop_list_screen.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/presentation/pages/ai_diagnosis_screen.dart';
import 'package:urban_smart_farming/features/settings/presentation/pages/settings_screen.dart';

/// Pantalla principal de navegación con BottomNavigationBar
/// Contiene las 3 pantallas principales: Mi Jardín, Diagnóstico IA, Ajustes
class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Lista de pantallas principales
    final List<Widget> screens = [
      const CropListScreen(),  // Mi Jardín
      const AiDiagnosisScreen(),  // Diagnóstico IA (placeholder)
      const SettingsScreen(),  // Ajustes
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.spa),
            label: 'Mi Jardín',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Diagnóstico IA',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
