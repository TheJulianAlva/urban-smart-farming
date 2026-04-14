import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urban_smart_farming/features/auth/domain/usecases/login_use_case.dart';
import 'package:urban_smart_farming/features/auth/domain/usecases/register_use_case.dart';
import 'package:urban_smart_farming/features/auth/domain/usecases/logout_use_case.dart';
import 'package:urban_smart_farming/features/auth/presentation/bloc/auth_event.dart';
import 'package:urban_smart_farming/features/auth/presentation/bloc/auth_state.dart';

/// BLoC para gestionar la autenticación
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  /// Maneja el evento de login
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await loginUseCase(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  /// Maneja el evento de registro
  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await registerUseCase(
      name: event.name,
      email: event.email,
      password: event.password,
      confirmPassword: event.confirmPassword,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  /// Maneja el evento de logout
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await logoutUseCase();
    emit(AuthLoggedOut());
  }
}
