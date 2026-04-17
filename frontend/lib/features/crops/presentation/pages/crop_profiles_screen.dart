import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urban_smart_farming/core/di/di_container.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/crop_profile.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/profiles_bloc.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/profiles_event.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/profiles_state.dart';
import 'package:urban_smart_farming/features/crops/presentation/widgets/profile_card.dart';

/// Pantalla de Perfiles de Cultivo.
/// Tab "Catálogo": 16 perfiles predefinidos (datos estáticos).
/// Tab "Mis Perfiles": perfiles personalizados del usuario (Supabase, async).
class CropProfilesScreen extends StatelessWidget {
  const CropProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfilesBloc>()..add(const LoadUserProfiles()),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Perfiles de Cultivo'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Catálogo'),
                Tab(text: 'Mis Perfiles'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              _CatalogTab(),
              _UserProfilesTab(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 1: Catálogo general — datos estáticos, sin BLoC
// ─────────────────────────────────────────────────────────────────────────────
class _CatalogTab extends StatelessWidget {
  const _CatalogTab();

  @override
  Widget build(BuildContext context) {
    final profiles = PredefinedProfiles.profiles;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        return ProfileCard(profile: profiles[index]);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 2: Mis perfiles — async vía ProfilesBloc
// ─────────────────────────────────────────────────────────────────────────────
class _UserProfilesTab extends StatelessWidget {
  const _UserProfilesTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfilesBloc, ProfilesState>(
      builder: (context, state) {
        if (state is ProfilesInitial || state is ProfilesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProfilesError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () =>
                      context.read<ProfilesBloc>().add(const LoadUserProfiles()),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (state is ProfilesLoaded) {
          if (state.userProfiles.isEmpty) {
            return _EmptyProfilesState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.userProfiles.length,
            itemBuilder: (context, index) {
              return ProfileCard(profile: state.userProfiles[index]);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _EmptyProfilesState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No tienes perfiles personalizados',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primer cultivo en modo experto para que aparezca aquí.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
