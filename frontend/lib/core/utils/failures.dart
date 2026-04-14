/// Tipos de fallas comunes en la aplicación
abstract class Failure {
  final String message;

  const Failure(this.message);
}

/// Falla de servidor/red
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Error de servidor']) : super(message);
}

/// Falla de autenticación
class AuthFailure extends Failure {
  const AuthFailure([String message = 'Error de autenticación'])
    : super(message);
}

/// Falla de validación
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Error de validación'])
    : super(message);
}

/// Falla de caché/almacenamiento
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Error de caché']) : super(message);
}
