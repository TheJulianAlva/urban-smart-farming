import 'package:flutter/material.dart';

/// Tipos de badges de estado para cultivos
enum BadgeType {
  needsWater, // Falta agua (humedad baja)
  needsLight, // Falta luz
  critical, // Problema crítico
}

/// Widget que muestra un badge de estado sobre una tarjeta de cultivo
class StatusBadge extends StatelessWidget {
  final BadgeType type;
  final double size;

  const StatusBadge({super.key, required this.type, this.size = 24});

  @override
  Widget build(BuildContext context) {
    final BadgeConfig config = _getBadgeConfig(type);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(config.icon, size: size * 0.6, color: Colors.white),
    );
  }

  BadgeConfig _getBadgeConfig(BadgeType type) {
    switch (type) {
      case BadgeType.needsWater:
        return BadgeConfig(
          icon: Icons.water_drop,
          backgroundColor: Colors.blue[700]!,
        );
      case BadgeType.needsLight:
        return BadgeConfig(
          icon: Icons.wb_sunny,
          backgroundColor: Colors.amber[700]!,
        );
      case BadgeType.critical:
        return BadgeConfig(
          icon: Icons.warning,
          backgroundColor: Colors.red[700]!,
        );
    }
  }
}

/// Configuración de un badge
class BadgeConfig {
  final IconData icon;
  final Color backgroundColor;

  BadgeConfig({required this.icon, required this.backgroundColor});
}
