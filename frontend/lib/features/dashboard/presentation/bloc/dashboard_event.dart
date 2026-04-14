import 'package:equatable/equatable.dart';

/// Eventos del Dashboard
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar datos iniciales del dashboard
class LoadDashboardData extends DashboardEvent {}

/// Refrescar datos del dashboard
class RefreshDashboardData extends DashboardEvent {}
