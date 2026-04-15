import 'package:dartz/dartz.dart';
import 'package:urban_smart_farming/core/utils/failures.dart';
import 'package:urban_smart_farming/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:urban_smart_farming/features/auth/domain/entities/user_entity.dart';
import 'package:urban_smart_farming/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(email: email, password: password);
      return Right(user);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (_) {
      return const Left(AuthFailure('Error inesperado al iniciar sesión.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
      );
      return Right(user);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (_) {
      return const Left(AuthFailure('Error inesperado al registrarse.'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (_) {
      return const Left(AuthFailure('Error al cerrar sesión.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } catch (_) {
      return const Left(AuthFailure('Error al obtener usuario actual.'));
    }
  }
}
