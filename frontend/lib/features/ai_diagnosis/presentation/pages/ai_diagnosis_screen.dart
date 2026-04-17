import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urban_smart_farming/core/theme/app_theme.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/presentation/bloc/ai_diagnosis_bloc.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/presentation/bloc/ai_diagnosis_event.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/presentation/bloc/ai_diagnosis_state.dart';

/// Pantalla de Diagnóstico con IA — embebida como tab en CropDetailScreen.
/// Recibe cropId y cropName del cultivo que se está analizando.
class AiDiagnosisScreen extends StatelessWidget {
  final String cropId;
  final String cropName;

  const AiDiagnosisScreen({
    required this.cropId,
    required this.cropName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AiDiagnosisBloc, AiDiagnosisState>(
      listener: (context, state) {
        if (state is AiDiagnosisError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _buildStateView(state),
        );
      },
    );
  }

  Widget _buildStateView(AiDiagnosisState state) {
    if (state is AiDiagnosisImageSelected) {
      return _ImageSelectedView(
        key: const ValueKey('image_selected'),
        imagePath: state.imagePath,
      );
    }
    if (state is AiDiagnosisAnalyzing) {
      return _AnalyzingView(
        key: const ValueKey('analyzing'),
        imagePath: state.imagePath,
      );
    }
    if (state is AiDiagnosisResult) {
      return _ResultView(key: const ValueKey('result'), result: state);
    }
    return _InitialView(key: const ValueKey('initial'), cropName: cropName);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ESTADO INICIAL — Hero section + botón de selección (con entrada animada)
// ─────────────────────────────────────────────────────────────────────────────
class _InitialView extends StatefulWidget {
  final String cropName;
  const _InitialView({super.key, required this.cropName});

  @override
  State<_InitialView> createState() => _InitialViewState();
}

class _InitialViewState extends State<_InitialView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _heroScale;
  late final Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _heroScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );
    _contentFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (pickedFile != null && context.mounted) {
      context.read<AiDiagnosisBloc>().add(ImageSelected(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 24),

          // Hero icon animado
          ScaleTransition(
            scale: _heroScale,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryGreenLight.withValues(alpha: 0.3),
                    AppTheme.primaryGreen.withValues(alpha: 0.15),
                  ],
                ),
              ),
              child: Icon(
                Icons.document_scanner_rounded,
                size: 60,
                color: AppTheme.primaryGreen.withValues(alpha: 0.8),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Contenido con fade-in
          FadeTransition(
            opacity: _contentFade,
            child: Column(
              children: [
                Text(
                  'Diagnóstico Inteligente',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  widget.cropName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Toma o selecciona una foto de tu planta y nuestra '
                  'IA analizará su estado para detectar posibles enfermedades, '
                  'plagas u otros problemas.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 36),

                // Tarjetas de características
                _FeatureCard(
                  icon: Icons.search_rounded,
                  title: 'Detección de Enfermedades',
                  subtitle:
                      'Identifica plagas, hongos y deficiencias nutricionales',
                ),
                const SizedBox(height: 12),
                _FeatureCard(
                  icon: Icons.medication_rounded,
                  title: 'Recomendaciones de Tratamiento',
                  subtitle:
                      'Recibe instrucciones paso a paso para tratar el problema',
                ),
                const SizedBox(height: 12),
                _FeatureCard(
                  icon: Icons.shield_rounded,
                  title: 'Consejos de Prevención',
                  subtitle: 'Aprende cómo evitar que el problema se repita',
                ),

                const SizedBox(height: 36),

                // Botón principal
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(context),
                    icon: const Icon(Icons.photo_library_rounded, size: 22),
                    label: const Text(
                      'Seleccionar Foto',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: AppTheme.primaryGreen.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de característica con icono
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.primaryGreenLight.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// IMAGEN SELECCIONADA — Preview + botón de analizar
// ─────────────────────────────────────────────────────────────────────────────
class _ImageSelectedView extends StatelessWidget {
  final String imagePath;
  const _ImageSelectedView({super.key, required this.imagePath});

  Future<void> _pickNewImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (pickedFile != null && context.mounted) {
      context.read<AiDiagnosisBloc>().add(ImageSelected(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Imagen seleccionada con bordes redondeados
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          color: AppTheme.backgroundLight,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              size: 64,
                              color: AppTheme.textHint,
                            ),
                          ),
                        ),
                  ),
                ),
                // Overlay con gradiente inferior
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.4),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ),
                // Botón de cambiar imagen
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _pickNewImage(context),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.swap_horiz_rounded, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Cambiar foto',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Texto informativo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.primaryGreenLight.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.primaryGreen,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Para mejores resultados, asegúrate de que la foto '
                    'muestre claramente las hojas o la zona afectada de '
                    'la planta.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Botón analizar
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<AiDiagnosisBloc>().add(AnalysisRequested());
              },
              icon: const Icon(Icons.auto_awesome_rounded, size: 22),
              label: const Text(
                'Analizar con IA',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 3,
                shadowColor: AppTheme.primaryGreen.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Botón cancelar
          TextButton(
            onPressed: () {
              context.read<AiDiagnosisBloc>().add(AnalysisReset());
            },
            child: const Text('Cancelar'),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANALIZANDO — Pulsing animation + pasos de análisis progresivos
// ─────────────────────────────────────────────────────────────────────────────
class _AnalyzingView extends StatefulWidget {
  final String imagePath;
  const _AnalyzingView({super.key, required this.imagePath});

  @override
  State<_AnalyzingView> createState() => _AnalyzingViewState();
}

class _AnalyzingViewState extends State<_AnalyzingView>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  late final AnimationController _stepsController;

  final List<String> _analysisSteps = [
    'Procesando imagen...',
    'Detectando patrones...',
    'Analizando hojas y tallos...',
    'Comparando con base de datos...',
    'Generando diagnóstico...',
  ];

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();

    // Pulsing animation para el indicador
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Stepper progresivo
    _stepsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..forward();

    _stepsController.addListener(() {
      final newStep = (_stepsController.value * _analysisSteps.length)
          .floor()
          .clamp(0, _analysisSteps.length - 1);
      if (newStep != _currentStep) {
        setState(() => _currentStep = newStep);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen miniatura con pulsing overlay
            ScaleTransition(
              scale: _pulseAnimation,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glow ring
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                        width: 3,
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(80),
                    child: SizedBox(
                      width: 160,
                      height: 160,
                      child: Opacity(
                        opacity: 0.6,
                        child: Image.file(
                          File(widget.imagePath),
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: AppTheme.backgroundLight,
                                child: const Icon(
                                  Icons.image_rounded,
                                  size: 48,
                                  color: AppTheme.textHint,
                                ),
                              ),
                        ),
                      ),
                    ),
                  ),
                  // Spinner sobre la imagen
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            Text(
              'Analizando imagen...',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 16),

            // Step progresivo animado
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _analysisSteps[_currentStep],
                key: ValueKey(_currentStep),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Esto puede tomar unos segundos',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textHint),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Progress dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_analysisSteps.length, (index) {
                final isActive = index <= _currentStep;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 10 : 8,
                  height: isActive ? 10 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isActive
                            ? AppTheme.primaryGreen
                            : AppTheme.primaryGreen.withValues(alpha: 0.2),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESULTADO — Diagnóstico y recomendaciones con staggered animation
// ─────────────────────────────────────────────────────────────────────────────
class _ResultView extends StatefulWidget {
  final AiDiagnosisResult result;
  const _ResultView({super.key, required this.result});

  @override
  State<_ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<_ResultView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  /// Crea una animación escalonada para cada elemento
  Animation<double> _staggeredFade(int index, int total) {
    final start = (index / total) * 0.6;
    final end = start + 0.4;
    return CurvedAnimation(
      parent: _staggerController,
      curve: Interval(
        start.clamp(0.0, 1.0),
        end.clamp(0.0, 1.0),
        curve: Curves.easeOut,
      ),
    );
  }

  Animation<Offset> _staggeredSlide(int index, int total) {
    final start = (index / total) * 0.6;
    final end = start + 0.4;
    return Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(
          start.clamp(0.0, 1.0),
          end.clamp(0.0, 1.0),
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'alta':
        return AppTheme.statusDanger;
      case 'moderada':
        return AppTheme.statusWarning;
      case 'baja':
        return AppTheme.statusOptimal;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _severityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'alta':
        return Icons.error_rounded;
      case 'moderada':
        return Icons.warning_amber_rounded;
      case 'baja':
        return Icons.check_circle_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final sevColor = _severityColor(result.severity);

    // Conteo total de elementos animados
    final totalItems =
        3 +
        result.recommendations.length +
        result.preventionTips.length; // header + 2 sections + tiles
    int itemIndex = 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header con imagen y diagnóstico ──
          FadeTransition(
            opacity: _staggeredFade(itemIndex, totalItems),
            child: SlideTransition(
              position: _staggeredSlide(itemIndex++, totalItems),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen con gradiente
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.file(
                              File(result.imagePath),
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    color: AppTheme.backgroundLight,
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_rounded,
                                        size: 48,
                                        color: AppTheme.textHint,
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.5),
                                  ],
                                  stops: const [0.5, 1.0],
                                ),
                              ),
                            ),
                          ),
                          // Badge de resultado
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 14,
                                    color: AppTheme.primaryGreen,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Análisis completado',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Contenido del diagnóstico
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Severidad
                          Row(
                            children: [
                              Icon(
                                _severityIcon(result.severity),
                                color: sevColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: sevColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Severidad: ${result.severity}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: sevColor,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Nombre del problema
                          Text(
                            result.problemName,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 6),

                          // Área afectada
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                result.affectedArea,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppTheme.textSecondary),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Descripción
                          Text(
                            result.problemDescription,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textPrimary.withValues(
                                alpha: 0.85,
                              ),
                              height: 1.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Sección de Recomendaciones ──
          FadeTransition(
            opacity: _staggeredFade(itemIndex, totalItems),
            child: SlideTransition(
              position: _staggeredSlide(itemIndex++, totalItems),
              child: _SectionHeader(
                icon: Icons.medication_rounded,
                title: 'Tratamiento Recomendado',
                color: AppTheme.statusWarning,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(result.recommendations.length, (index) {
            final i = itemIndex++;
            return FadeTransition(
              opacity: _staggeredFade(i, totalItems),
              child: SlideTransition(
                position: _staggeredSlide(i, totalItems),
                child: _RecommendationTile(
                  number: index + 1,
                  text: result.recommendations[index],
                  color: AppTheme.statusWarning,
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // ── Sección de Prevención ──
          FadeTransition(
            opacity: _staggeredFade(itemIndex, totalItems),
            child: SlideTransition(
              position: _staggeredSlide(itemIndex++, totalItems),
              child: _SectionHeader(
                icon: Icons.shield_rounded,
                title: 'Consejos de Prevención',
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(result.preventionTips.length, (index) {
            final i = itemIndex++;
            return FadeTransition(
              opacity: _staggeredFade(i, totalItems),
              child: SlideTransition(
                position: _staggeredSlide(i, totalItems),
                child: _RecommendationTile(
                  number: index + 1,
                  text: result.preventionTips[index],
                  color: AppTheme.primaryGreen,
                ),
              ),
            );
          }),

          const SizedBox(height: 32),

          // ── Botón nuevo diagnóstico ──
          FadeTransition(
            opacity: _staggeredFade(totalItems - 1, totalItems),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<AiDiagnosisBloc>().add(AnalysisReset());
                },
                icon: const Icon(Icons.refresh_rounded, size: 22),
                label: const Text(
                  'Nuevo Diagnóstico',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shadowColor: AppTheme.primaryGreen.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Header de sección con icono y título
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

/// Tile numerado para recomendaciones y prevención
class _RecommendationTile extends StatelessWidget {
  final int number;
  final String text;
  final Color color;

  const _RecommendationTile({
    required this.number,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                  color: AppTheme.textPrimary.withValues(alpha: 0.85),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
