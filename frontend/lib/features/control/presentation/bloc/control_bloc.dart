import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urban_smart_farming/features/control/domain/repositories/control_repository.dart';
import 'package:urban_smart_farming/features/control/presentation/bloc/control_event.dart';
import 'package:urban_smart_farming/features/control/presentation/bloc/control_state.dart';

class ControlBloc extends Bloc<ControlEvent, ControlState> {
  final String cropId;
  final ControlRepository controlRepository;

  ControlLoaded? _currentState;
  String? _deviceId;

  ControlBloc({required this.cropId, required this.controlRepository})
      : super(ControlInitial()) {
    on<LoadControlData>(_onLoadControlData);
    on<ToggleAutomaticMode>(_onToggleAutomaticMode);
    on<TogglePump>(_onTogglePump);
    on<ToggleLight>(_onToggleLight);
    on<SetLightIntensity>(_onSetLightIntensity);
  }

  Future<void> _onLoadControlData(
    LoadControlData event,
    Emitter<ControlState> emit,
  ) async {
    emit(ControlLoading());
    try {
      _deviceId = await controlRepository.getDeviceId(cropId);
      if (_deviceId == null) {
        emit(const ControlError('Este cultivo no tiene un dispositivo registrado'));
        return;
      }
      final states = await controlRepository.getActuatorStates(_deviceId!);
      _currentState = ControlLoaded(
        isAutomaticMode: true,
        isPumpOn: states.isPumpOn,
        isLightOn: states.isLightOn,
        lightIntensity: states.isLightOn ? 100 : 0,
      );
      emit(_currentState!);
    } catch (e) {
      emit(ControlError('Error al cargar el control: $e'));
    }
  }

  Future<void> _onToggleAutomaticMode(
    ToggleAutomaticMode event,
    Emitter<ControlState> emit,
  ) async {
    if (_currentState == null) return;

    emit(
      ControlUpdating(
        event.isAutomatic ? 'Activando modo automático...' : 'Activando modo manual...',
      ),
    );

    await Future.delayed(const Duration(milliseconds: 200));

    _currentState = _currentState!.copyWith(
      isAutomaticMode: event.isAutomatic,
      isPumpOn: event.isAutomatic ? false : _currentState!.isPumpOn,
      isLightOn: event.isAutomatic ? false : _currentState!.isLightOn,
      lightIntensity: event.isAutomatic ? 0 : _currentState!.lightIntensity,
    );
    emit(_currentState!);
  }

  Future<void> _onTogglePump(
    TogglePump event,
    Emitter<ControlState> emit,
  ) async {
    if (_currentState == null || _currentState!.isAutomaticMode || _deviceId == null) return;

    emit(ControlUpdating(event.isOn ? 'Activando riego...' : 'Desactivando riego...'));
    try {
      await controlRepository.actuate(_deviceId!, 'pump', event.isOn ? 'on' : 'off');
      _currentState = _currentState!.copyWith(isPumpOn: event.isOn);
      emit(_currentState!);
    } catch (_) {
      emit(_currentState!); // Revertir UI al estado previo
    }
  }

  Future<void> _onToggleLight(
    ToggleLight event,
    Emitter<ControlState> emit,
  ) async {
    if (_currentState == null || _currentState!.isAutomaticMode || _deviceId == null) return;

    emit(ControlUpdating(event.isOn ? 'Encendiendo luz...' : 'Apagando luz...'));
    try {
      await controlRepository.actuate(_deviceId!, 'light', event.isOn ? 'on' : 'off');
      _currentState = _currentState!.copyWith(
        isLightOn: event.isOn,
        lightIntensity: event.isOn ? 100 : 0,
      );
      emit(_currentState!);
    } catch (_) {
      emit(_currentState!); // Revertir UI al estado previo
    }
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
}
