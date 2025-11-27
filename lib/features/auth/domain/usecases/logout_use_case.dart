import 'package:dartz/dartz.dart';
import 'package:urban_smart_farming/core/utils/failures.dart';
import 'package:urban_smart_farming/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso para cerrar sesión
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.logout();
  }
}
