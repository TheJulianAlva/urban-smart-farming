import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urban_smart_farming/core/utils/constants.dart';
import 'package:urban_smart_farming/features/dashboard/domain/usecases/get_sensor_data_use_case.dart';
import 'package:urban_smart_farming/features/dashboard/domain/usecases/get_actuator_statuses_use_case.dart';
import 'package:urban_smart_farming/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:urban_smart_farming/features/dashboard/presentation/bloc/dashboard_state.dart';

/// BLoC del Dashboard con auto-refresh
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetSensorDataUseCase getSensorDataUseCase;
  final GetActuatorStatusesUseCase getActuatorStatusesUseCase;

  Timer? _refreshTimer;

  DashboardBloc({
    required this.getSensorDataUseCase,
    required this.getActuatorStatusesUseCase,
  }) : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);

    // Iniciar auto-refresh
    _startAutoRefresh();
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    await _loadData(emit);
  }

  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<DashboardState> emit) async {
    final sensorResult = await getSensorDataUseCase();
    final actuatorsResult = await getActuatorStatusesUseCase();

    sensorResult.fold((failure) => emit(DashboardError(failure.message)), (
      sensorData,
    ) {
      actuatorsResult.fold(
        (failure) => emit(DashboardError(failure.message)),
        (actuators) =>
            emit(DashboardLoaded(sensorData: sensorData, actuators: actuators)),
      );
    });
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(
      const Duration(seconds: AppConstants.dashboardRefreshInterval),
      (_) => add(RefreshDashboardData()),
    );
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
