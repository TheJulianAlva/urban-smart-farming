import 'package:equatable/equatable.dart';

/// Estados del BLoC de control de cultivos
abstract class ControlState extends Equatable {
  const ControlState();

  @override
  List<Object?> get props => [];
}

class ControlInitial extends ControlState {}

class ControlLoading extends ControlState {}

class ControlLoaded extends ControlState {
  final bool isAutomaticMode;
  final bool isPumpOn;
  final bool isLightOn;
  final int lightIntensity; // 0-100
  final bool isFanOn;

  const ControlLoaded({
    required this.isAutomaticMode,
    required this.isPumpOn,
    required this.isLightOn,
    required this.lightIntensity,
    required this.isFanOn,
  });

  @override
  List<Object?> get props => [
    isAutomaticMode,
    isPumpOn,
    isLightOn,
    lightIntensity,
    isFanOn,
  ];

  ControlLoaded copyWith({
    bool? isAutomaticMode,
    bool? isPumpOn,
    bool? isLightOn,
    int? lightIntensity,
    bool? isFanOn,
  }) {
    return ControlLoaded(
      isAutomaticMode: isAutomaticMode ?? this.isAutomaticMode,
      isPumpOn: isPumpOn ?? this.isPumpOn,
      isLightOn: isLightOn ?? this.isLightOn,
      lightIntensity: lightIntensity ?? this.lightIntensity,
      isFanOn: isFanOn ?? this.isFanOn,
    );
  }
}

class ControlError extends ControlState {
  final String message;

  const ControlError(this.message);

  @override
  List<Object?> get props => [message];
}

class ControlUpdating extends ControlState {
  final String action; // Para mostrar "Activando riego...", etc.

  const ControlUpdating(this.action);

  @override
  List<Object?> get props => [action];
}
