import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:urban_smart_farming/core/di/di_container.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/crop_profile.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/pot.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/crops_bloc.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/crops_event.dart';
import 'package:urban_smart_farming/features/crops/presentation/widgets/wizard_step_1_basic_info.dart';
import 'package:urban_smart_farming/features/crops/presentation/widgets/wizard_step_2_hardware.dart';
import 'package:urban_smart_farming/features/crops/presentation/widgets/wizard_step_3_profile.dart';
import 'package:urban_smart_farming/features/crops/presentation/widgets/wizard_step_4_summary.dart';

/// Wizard multi-paso para crear un nuevo cultivo
class CropCreationWizardScreen extends StatefulWidget {
  const CropCreationWizardScreen({super.key});

  @override
  State<CropCreationWizardScreen> createState() =>
      _CropCreationWizardScreenState();
}

class _CropCreationWizardScreenState extends State<CropCreationWizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Datos del wizard
  String _cropName = '';
  String _cropLocation = '';
  Pot? _selectedPot;
  CropProfile? _selectedProfile;
  bool _isExpertMode = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0:
        return _cropName.trim().isNotEmpty && _cropLocation.trim().isNotEmpty;
      case 1:
        return true; // Hardware es opcional
      case 2:
        return _selectedProfile != null;
      case 3:
        return true; // Summary siempre permite proceder
      default:
        return false;
    }
  }

  void _createCrop() {
    if (_cropName.isEmpty || _selectedProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos requeridos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Agregar cultivo con el Bloc usando inyección de dependencias
    getIt<CropsBloc>().add(
      AddCrop(
        name: _cropName,
        location: _cropLocation,
        profile: _selectedProfile!,
        hardwareId:
            _selectedPot?.hardwareId, // Usar hardwareId del pot si existe
      ),
    );

    // Mostrar confirmación y volver
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cultivo "$_cropName" creado exitosamente'),
        backgroundColor: Colors.green,
      ),
    );

    // Navegar de vuelta al home
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Cultivo'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / 4,
            backgroundColor: Colors.grey[200],
          ),
        ),
      ),
      body: Column(
        children: [
          // Indicador de pasos
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: List.generate(4, (index) {
                final isActive = index == _currentStep;
                final isCompleted = index < _currentStep;

                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color:
                                isCompleted || isActive
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      if (index < 3) const SizedBox(width: 4),
                    ],
                  ),
                );
              }),
            ),
          ),

          // Contenido del paso actual
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Paso 1: Datos Básicos
                WizardStep1BasicInfo(
                  initialName: _cropName,
                  initialLocation: _cropLocation,
                  onDataChanged: (name, location) {
                    setState(() {
                      _cropName = name;
                      _cropLocation = location;
                    });
                  },
                ),

                // Paso 2: Hardware
                WizardStep2Hardware(
                  initialPot: _selectedPot,
                  onDataChanged: (pot, skipHardware) {
                    setState(() {
                      _selectedPot = pot;
                      // skipHardware no se usa, solo almacenamos el pot
                    });
                  },
                ),

                // Paso 3: Perfil
                WizardStep3Profile(
                  initialProfile: _selectedProfile,
                  initialIsExpertMode: _isExpertMode,
                  onDataChanged: (profile, isExpertMode) {
                    setState(() {
                      _selectedProfile = profile;
                      _isExpertMode = isExpertMode;
                    });
                  },
                ),

                // Paso 4: Resumen
                WizardStep4Summary(
                  name: _cropName,
                  location: _cropLocation,
                  hardwareId: _selectedPot?.hardwareId,
                  profile:
                      _selectedProfile ?? PredefinedProfiles.profiles.first,
                ),
              ],
            ),
          ),

          // Botones de navegación
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Botón Anterior
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        child: const Text('Anterior'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),

                  // Botón Siguiente/Crear
                  Expanded(
                    flex: _currentStep == 0 ? 1 : 1,
                    child: ElevatedButton(
                      onPressed:
                          _canProceedToNextStep()
                              ? (_currentStep == 3 ? _createCrop : _nextStep)
                              : null,
                      child: Text(
                        _currentStep == 3 ? 'Crear Cultivo' : 'Siguiente',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
