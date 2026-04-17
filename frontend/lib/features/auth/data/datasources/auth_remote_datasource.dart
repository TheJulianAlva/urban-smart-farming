import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urban_smart_farming/core/utils/failures.dart';
import 'package:urban_smart_farming/features/auth/domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<UserEntity> login({required String email, required String password});
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
  });
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) throw const AuthFailure('No se pudo iniciar sesión.');
      return _toEntity(user);
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthError(e.message));
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw const AuthFailure('Error al conectar con el servidor.');
    }
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      if (response.session == null) {
        throw const EmailConfirmationFailure();
      }
      final user = response.user;
      if (user == null) throw const AuthFailure('No se pudo completar el registro.');
      return _toEntity(user);
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthError(e.message));
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw const AuthFailure('Error al conectar con el servidor.');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthError(e.message));
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _toEntity(user);
  }

  UserEntity _toEntity(User user) {
    final name = user.userMetadata?['name'] as String? ??
        user.email?.split('@').first ??
        'Usuario';
    return UserEntity(id: user.id, name: name, email: user.email ?? '');
  }

  String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Email o contraseña incorrectos.';
    }
    if (message.contains('Email not confirmed')) {
      return 'Confirmá tu email antes de iniciar sesión.';
    }
    if (message.contains('User already registered')) {
      return 'Ya existe una cuenta con ese email.';
    }
    if (message.contains('Password should be at least')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    return message;
  }
}
