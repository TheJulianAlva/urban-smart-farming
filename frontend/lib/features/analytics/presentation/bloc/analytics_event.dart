import 'package:equatable/equatable.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

/// Carga historial para un rango dado (por defecto 'day')
class LoadAnalyticsData extends AnalyticsEvent {
  final String range;

  const LoadAnalyticsData({this.range = 'day'});

  @override
  List<Object?> get props => [range];
}

/// El usuario cambió el selector de rango temporal
class ChangeRange extends AnalyticsEvent {
  final String range;

  const ChangeRange(this.range);

  @override
  List<Object?> get props => [range];
}
