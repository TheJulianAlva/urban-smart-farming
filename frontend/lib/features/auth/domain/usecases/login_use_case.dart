import 'package:dartz/dartz.dart';
import 'package:urban_smart_farming/core/utils/failures.dart';
import 'package:urban_smart_farming/features/auth/domain/entities/user_entity.dart';
import 'package:urban_smart_farming/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso para iniciar sesión
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  /// Ejecuta el login con validaciones
  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    // Validar formato de email
    if (!_isValidEmail(email)) {
      return const Left(ValidationFailure('Formato de email inválido'));
    }

    // Validar longitud de contraseña
    if (password.length < 6) {
      return const Left(
        ValidationFailure('La contraseña debe tener al menos 6 caracteres'),
      );
    }

    return await repository.login(email: email, password: password);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
