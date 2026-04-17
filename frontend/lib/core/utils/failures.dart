/// Tipos de fallas comunes en la aplicación
abstract class Failure {
  final String message;

  const Failure(this.message);
}

/// Falla de servidor/red
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error de servidor']);
}

/// Falla de autenticación
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Error de autenticación']);
}

/// Falla de validación
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Error de validación']);
}

/// Falla de caché/almacenamiento
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error de caché']);
}

/// Falla de confirmación de email pendiente
class EmailConfirmationFailure extends Failure {
  const EmailConfirmationFailure(
      [super.message =
          'Registro exitoso. Por favor, revisa tu email y confirma tu cuenta antes de iniciar sesión.']);
}
