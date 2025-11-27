import 'package:get_it/get_it.dart';
import 'package:urban_smart_farming/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:urban_smart_farming/features/auth/domain/repositories/auth_repository.dart';
import 'package:urban_smart_farming/features/auth/domain/usecases/login_use_case.dart';
import 'package:urban_smart_farming/features/auth/domain/usecases/register_use_case.dart';
import 'package:urban_smart_farming/features/auth/domain/usecases/logout_use_case.dart';
import 'package:urban_smart_farming/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:urban_smart_farming/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:urban_smart_farming/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:urban_smart_farming/features/dashboard/domain/usecases/get_sensor_data_use_case.dart';
import 'package:urban_smart_farming/features/dashboard/domain/usecases/get_actuator_statuses_use_case.dart';
import 'package:urban_smart_farming/features/dashboard/presentation/bloc/dashboard_bloc.dart';

/// Service locator para Dependency Injection
final getIt = GetIt.instance;

/// Configura todas las dependencias de la aplicación
Future<void> setupDependencies() async {
  // Repositorios
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(),
  );

  // Use Cases - Auth
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));

  // Use Cases - Dashboard
  getIt.registerLazySingleton(() => GetSensorDataUseCase(getIt()));
  getIt.registerLazySingleton(() => GetActuatorStatusesUseCase(getIt()));

  // BLoCs
  getIt.registerFactory(
    () => AuthBloc(
      loginUseCase: getIt(),
      registerUseCase: getIt(),
      logoutUseCase: getIt(),
    ),
  );

  getIt.registerFactory(
    () => DashboardBloc(
      getSensorDataUseCase: getIt(),
      getActuatorStatusesUseCase: getIt(),
    ),
  );
}
