import 'package:flutter/material.dart';
import 'package:urban_smart_farming/features/crops/presentation/pages/crop_list_screen.dart';
import 'package:urban_smart_farming/features/settings/presentation/pages/settings_screen.dart';

/// Pantalla principal de navegación con BottomNavigationBar
/// Contiene las 2 pantallas principales: Mi Jardín, Ajustes
class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;
  Key _gardenKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      CropListScreen(key: _gardenKey),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            if (index == 0 && _currentIndex == 0) {
              _gardenKey = UniqueKey();
            }
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.spa), label: 'Mi Jardín'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}
