import 'package:flutter/material.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/crop_profile.dart';

/// Tarjeta reutilizable para mostrar un PlantProfile.
/// Usada en el wizard de creación (seleccionable) y en CropProfilesScreen (solo lectura).
class ProfileCard extends StatelessWidget {
  final PlantProfile profile;
  final bool isSelected;
  final VoidCallback? onTap;

  const ProfileCard({
    super.key,
    required this.profile,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        leading: Icon(
          Icons.eco,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.green,
        ),
        title: Text(
          profile.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(profile.description),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(
                    '💧 ${profile.minSoilMoisture.toStringAsFixed(0)}-${profile.maxSoilMoisture.toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 11),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Chip(
                  label: Text(
                    '🌡️ ${profile.minTemperature.toStringAsFixed(0)}-${profile.maxTemperature.toStringAsFixed(0)}°C',
                    style: const TextStyle(fontSize: 11),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Chip(
                  label: Text(
                    '☀️ ${profile.requiredLightHours}h',
                    style: const TextStyle(fontSize: 11),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Chip(
                  label: Text(
                    '🧪 pH ${profile.minPH.toStringAsFixed(1)}-${profile.maxPH.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ],
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle,
                color: Theme.of(context).colorScheme.primary)
            : null,
        isThreeLine: true,
        onTap: onTap,
      ),
    );
  }
}
