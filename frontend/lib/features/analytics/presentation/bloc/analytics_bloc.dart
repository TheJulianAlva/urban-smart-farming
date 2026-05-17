import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urban_smart_farming/features/analytics/domain/usecases/get_sensor_history_use_case.dart';
import 'package:urban_smart_farming/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:urban_smart_farming/features/analytics/presentation/bloc/analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final String cropId;
  final GetSensorHistoryUseCase getSensorHistoryUseCase;

  AnalyticsBloc({
    required this.cropId,
    required this.getSensorHistoryUseCase,
  }) : super(AnalyticsInitial()) {
    on<LoadAnalyticsData>(_onLoad);
    on<ChangeRange>(_onChangeRange);
  }

  Future<void> _onLoad(
    LoadAnalyticsData event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());
    final result = await getSensorHistoryUseCase(cropId, event.range);
    result.fold(
      (failure) => emit(AnalyticsError(message: failure.message, range: event.range)),
      (readings) => readings.isEmpty
          ? emit(AnalyticsEmpty(event.range))
          : emit(AnalyticsLoaded(readings: readings, range: event.range)),
    );
  }

  Future<void> _onChangeRange(
    ChangeRange event,
    Emitter<AnalyticsState> emit,
  ) async {
    add(LoadAnalyticsData(range: event.range));
  }
}
