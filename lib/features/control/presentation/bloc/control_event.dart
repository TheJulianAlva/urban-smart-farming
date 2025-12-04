import 'package:equatable/equatable.dart';

/// Eventos del BLoC de control
abstract class ControlEvent extends Equatable {
  const ControlEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar estado inicial del control
class LoadControlData extends ControlEvent {
  final String cropId;

  const LoadControlData(this.cropId);

  @override
  List<Object?> get props => [cropId];
}

/// Cambiar entre modo automático y manual
class ToggleAutomaticMode extends ControlEvent {
  final bool isAutomatic;

  const ToggleAutomaticMode(this.isAutomatic);

  @override
  List<Object?> get props => [isAutomatic];
}

/// Activar/desactivar bomba de riego
class TogglePump extends ControlEvent {
  final bool isOn;

  const TogglePump(this.isOn);

  @override
  List<Object?> get props => [isOn];
}

/// Activar/desactivar luz
class ToggleLight extends ControlEvent {
  final bool isOn;

  const ToggleLight(this.isOn);

  @override
  List<Object?> get props => [isOn];
}

/// Cambiar intensidad de luz
class SetLightIntensity extends ControlEvent {
  final int intensity; // 0-100

  const SetLightIntensity(this.intensity);

  @override
  List<Object?> get props => [intensity];
}

/// Activar/desactivar ventilador
class ToggleFan extends ControlEvent {
  final bool isOn;

  const ToggleFan(this.isOn);

  @override
  List<Object?> get props => [isOn];
}
