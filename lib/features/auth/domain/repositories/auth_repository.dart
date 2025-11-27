import 'package:dartz/dartz.dart';
import 'package:urban_smart_farming/core/utils/failures.dart';
import 'package:urban_smart_farming/features/auth/domain/entities/user_entity.dart';

/// Repositorio de autenticación (contrato)
abstract class AuthRepository {
  /// Iniciar sesión con email y contraseña
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  /// Registrar nuevo usuario
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
  });

  /// Cerrar sesión
  Future<Either<Failure, void>> logout();

  /// Obtener usuario actual si existe sesión activa
  Future<Either<Failure, UserEntity?>> getCurrentUser();
}
