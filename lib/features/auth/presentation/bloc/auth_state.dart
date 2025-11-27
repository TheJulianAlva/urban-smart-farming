import 'package:equatable/equatable.dart';
import 'package:urban_smart_farming/features/auth/domain/entities/user_entity.dart';

/// Estados del BLoC de autenticación
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AuthInitial extends AuthState {}

/// Estado de carga (procesando login/registro)
class AuthLoading extends AuthState {}

/// Estado de éxito con usuario autenticado
class AuthSuccess extends AuthState {
  final UserEntity user;

  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

/// Estado de error
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado de logout exitoso
class AuthLoggedOut extends AuthState {}
