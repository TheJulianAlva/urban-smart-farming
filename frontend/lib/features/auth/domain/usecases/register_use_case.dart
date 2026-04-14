import 'package:dartz/dartz.dart';
import 'package:urban_smart_farming/core/utils/failures.dart';
import 'package:urban_smart_farming/features/auth/domain/entities/user_entity.dart';
import 'package:urban_smart_farming/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso para registrar nuevo usuario
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  /// Ejecuta el registro con validaciones
  Future<Either<Failure, UserEntity>> call({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    // Validar nombre
    if (name.trim().isEmpty) {
      return const Left(ValidationFailure('El nombre es requerido'));
    }

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

    // Validar que las contraseñas coincidan
    if (password != confirmPassword) {
      return const Left(ValidationFailure('Las contraseñas no coinciden'));
    }

    return await repository.register(
      name: name,
      email: email,
      password: password,
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
