import 'package:equatable/equatable.dart';
import 'package:urban_smart_farming/features/analytics/domain/entities/sensor_reading_history_entity.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final List<SensorReadingHistoryEntity> readings;
  final String range;

  const AnalyticsLoaded({required this.readings, required this.range});

  @override
  List<Object?> get props => [readings, range];
}

/// Lista vacía — no hay lecturas para este rango
class AnalyticsEmpty extends AnalyticsState {
  final String range;

  const AnalyticsEmpty(this.range);

  @override
  List<Object?> get props => [range];
}

class AnalyticsError extends AnalyticsState {
  final String message;
  final String range;

  const AnalyticsError({required this.message, required this.range});

  @override
  List<Object?> get props => [message, range];
}
