import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:urban_smart_farming/core/routing/app_router.dart';
import 'package:urban_smart_farming/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:urban_smart_farming/features/auth/presentation/bloc/auth_event.dart';
import 'package:urban_smart_farming/features/auth/presentation/bloc/auth_state.dart';

/// Pantalla de autenticación con tabs de Login y Registro (S-01)
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers para Login
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Controllers para Registro
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();

  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Navegar al dashboard tras autenticación exitosa
            context.go(AppRouter.main);
          } else if (state is AuthError) {
            // Mostrar error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // Logo y título
              const SizedBox(height: 40),
              Icon(
                Icons.eco,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Urban Smart Farming',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Sistema Inteligente de Agricultura Urbana',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // TabBar
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Iniciar Sesión'),
                  Tab(text: 'Registrarse'),
                ],
              ),

              // TabBarView
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildLoginTab(), _buildRegisterTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tab de Login
  Widget _buildLoginTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // Email
            TextFormField(
              controller: _loginEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu email';
                }
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) {
                  return 'Formato de email inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password
            TextFormField(
              controller: _loginPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: Icon(Icons.lock),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu contraseña';
                }
                if (value.length < 6) {
                  return 'La contraseña debe tener al menos 6 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Botón de Login
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;

                return ElevatedButton(
                  onPressed: isLoading ? null : _handleLogin,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child:
                        isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Entrar'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Tab de Registro
  Widget _buildRegisterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // Nombre
            TextFormField(
              controller: _registerNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa tu nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _registerEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu email';
                }
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) {
                  return 'Formato de email inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password
            TextFormField(
              controller: _registerPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: Icon(Icons.lock),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa una contraseña';
                }
                if (value.length < 6) {
                  return 'La contraseña debe tener al menos 6 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Confirm Password
            TextFormField(
              controller: _registerConfirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmar Contraseña',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor confirma tu contraseña';
                }
                if (value != _registerPasswordController.text) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Botón de Registro
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;

                return ElevatedButton(
                  onPressed: isLoading ? null : _handleRegister,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child:
                        isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Registrar'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_loginFormKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginRequested(
          email: _loginEmailController.text,
          password: _loginPasswordController.text,
        ),
      );
    }
  }

  void _handleRegister() {
    if (_registerFormKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        RegisterRequested(
          name: _registerNameController.text,
          email: _registerEmailController.text,
          password: _registerPasswordController.text,
          confirmPassword: _registerConfirmPasswordController.text,
        ),
      );
    }
  }
}
