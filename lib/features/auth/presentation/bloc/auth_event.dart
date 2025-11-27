import 'package:equatable/equatable.dart';

/// Eventos del BLoC de autenticación
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para solicitar login
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Evento para solicitar registro
class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  const RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [name, email, password, confirmPassword];
}

/// Evento para solicitar logout
class LogoutRequested extends AuthEvent {}
