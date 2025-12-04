import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urban_smart_farming/features/control/presentation/bloc/control_event.dart';
import 'package:urban_smart_farming/features/control/presentation/bloc/control_state.dart';

/// BLoC para control de actuadores de cultivos
class ControlBloc extends Bloc<ControlEvent, ControlState> {
  ControlBloc() : super(ControlInitial()) {
    on<LoadControlData>(_onLoadControlData);
    on<ToggleAutomaticMode>(_onToggleAutomaticMode);
    on<TogglePump>(_onTogglePump);
    on<ToggleLight>(_onToggleLight);
    on<SetLightIntensity>(_onSetLightIntensity);
    on<ToggleFan>(_onToggleFan);
  }

  // Estado actual (lo mantenemos aquí para simplificar)
  ControlLoaded? _currentState;

  Future<void> _onLoadControlData(
    LoadControlData event,
    Emitter<ControlState> emit,
  ) async {
    emit(ControlLoading());

    // Simular carga de datos (mockup)
    await Future.delayed(const Duration(milliseconds: 500));

    _currentState = const ControlLoaded(
      isAutomaticMode: true, // Por defecto en modo automático
      isPumpOn: false,
      isLightOn: false,
      lightIntensity: 0,
      isFanOn: false,
    );

    emit(_currentState!);
  }

  Future<void> _onToggleAutomaticMode(
    ToggleAutomaticMode event,
    Emitter<ControlState> emit,
  ) async {
    if (_currentState == null) return;

    emit(
      ControlUpdating(
        event.isAutomatic
            ? 'Activando modo automático...'
            : 'Activando modo manual...',
      ),
    );

    // Simular petición al backend
    await Future.delayed(const Duration(milliseconds: 300));

    _currentState = _currentState!.copyWith(
      isAutomaticMode: event.isAutomatic,
      // Si activamos automático, apagamos controles manuales
      isPumpOn: event.isAutomatic ? false : _currentState!.isPumpOn,
      isLightOn: event.isAutomatic ? false : _currentState!.isLightOn,
      isFanOn: event.isAutomatic ? false : _currentState!.isFanOn,
    );

    emit(_currentState!);
  }

  Future<void> _onTogglePump(
    TogglePump event,
    Emitter<ControlState> emit,
  ) async {
    if (_currentState == null || _currentState!.isAutomaticMode) return;

    emit(
      ControlUpdating(
        event.isOn ? 'Activando riego...' : 'Desactivando riego...',
      ),
    );

    // Simular petición al hardware
    await Future.delayed(const Duration(milliseconds: 500));

    _currentState = _currentState!.copyWith(isPumpOn: event.isOn);
    emit(_currentState!);
  }

  Future<void> _onToggleLight(
    ToggleLight event,
    Emitter<ControlState> emit,
  ) async {
    if (_currentState == null || _currentState!.isAutomaticMode) return;

    emit(
      ControlUpdating(event.isOn ? 'Encendiendo luz...' : 'Apagando luz...'),
    );

    await Future.delayed(const Duration(milliseconds: 500));

    _currentState = _currentState!.copyWith(
      isLightOn: event.isOn,
      lightIntensity: event.isOn ? 100 : 0,
    );
    emit(_currentState!);
  }

  Future<void> _onSetLightIntensity(
    SetLightIntensity event,
    Emitter<ControlState> emit,
  ) async {
    if (_currentState == null || _currentState!.isAutomaticMode) return;

    _currentState = _currentState!.copyWith(
      lightIntensity: event.intensity,
      isLightOn: event.intensity > 0,
    );
    emit(_currentState!);
  }

  Future<void> _onToggleFan(ToggleFan event, Emitter<ControlState> emit) async {
    if (_currentState == null || _currentState!.isAutomaticMode) return;

    emit(
      ControlUpdating(
        event.isOn ? 'Activando ventilación...' : 'Desactivando ventilación...',
      ),
    );

    await Future.delayed(const Duration(milliseconds: 500));

    _currentState = _currentState!.copyWith(isFanOn: event.isOn);
    emit(_currentState!);
  }
}
