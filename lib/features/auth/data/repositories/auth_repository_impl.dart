import 'package:dartz/dartz.dart';
import 'package:urban_smart_farming/core/utils/failures.dart';
import 'package:urban_smart_farming/features/auth/domain/entities/user_entity.dart';
import 'package:urban_smart_farming/features/auth/domain/repositories/auth_repository.dart';

/// Implementación mock del repositorio de autenticación
/// Simula latencia de red y acepta cualquier email/password válidos
class AuthRepositoryImpl implements AuthRepository {
  UserEntity? _currentUser;

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    // Simular latencia de red
    await Future.delayed(const Duration(seconds: 1));

    // Mock: acepta cualquier email/password con formato válido
    final user = UserEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: email.split('@').first,
      email: email,
    );

    _currentUser = user;
    return Right(user);
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Simular latencia de red
    await Future.delayed(const Duration(milliseconds: 1500));

    // Mock: crear usuario con los datos proporcionados
    final user = UserEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
    );

    _currentUser = user;
    return Right(user);
  }

  @override
  Future<Either<Failure, void>> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    return const Right(null);
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    return Right(_currentUser);
  }
}
