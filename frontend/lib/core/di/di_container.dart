import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:urban_smart_farming/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:urban_smart_farming/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:urban_smart_farming/features/auth/domain/repositories/auth_repository.dart';
import 'package:urban_smart_farming/features/auth/domain/usecases/login_use_case.dart';
import 'package:urban_smart_farming/features/auth/domain/usecases/register_use_case.dart';
import 'package:urban_smart_farming/features/auth/domain/usecases/logout_use_case.dart';
import 'package:urban_smart_farming/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:urban_smart_farming/features/crops/data/repositories/crop_repository_impl.dart';
import 'package:urban_smart_farming/features/crops/domain/repositories/crop_repository.dart';
import 'package:urban_smart_farming/features/crops/domain/usecases/get_user_crops_use_case.dart';
import 'package:urban_smart_farming/features/crops/domain/usecases/create_crop_use_case.dart';
import 'package:urban_smart_farming/features/crops/domain/usecases/delete_crop_use_case.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/crops_bloc.dart';

import 'package:urban_smart_farming/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:urban_smart_farming/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:urban_smart_farming/features/dashboard/domain/usecases/get_sensor_data_use_case.dart';
import 'package:urban_smart_farming/features/dashboard/domain/usecases/get_actuator_statuses_use_case.dart';
import 'package:urban_smart_farming/features/dashboard/presentation/bloc/dashboard_bloc.dart';

import 'package:urban_smart_farming/features/ai_diagnosis/data/datasources/ai_diagnosis_remote_datasource.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/data/repositories/ai_diagnosis_repository_impl.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/domain/repositories/ai_diagnosis_repository.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/domain/usecases/analyze_crop_image.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/presentation/bloc/ai_diagnosis_bloc.dart';

/// Service locator para Dependency Injection
final getIt = GetIt.instance;

/// Configura todas las dependencias de la aplicación
Future<void> setupDependencies() async {
  // Auth - datasource y repositorio
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton<CropRepository>(() => CropRepositoryImpl());
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(),
  );

  // Use Cases - Auth
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));

  // Use Cases - Crops
  getIt.registerLazySingleton(() => GetUserCropsUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateCropUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteCropUseCase(getIt()));

  // Use Cases - Dashboard
  getIt.registerLazySingleton(() => GetSensorDataUseCase(getIt()));
  getIt.registerLazySingleton(() => GetActuatorStatusesUseCase(getIt()));

  // AiDiagnosis - datasource, repositorio y use case
  getIt.registerLazySingleton<AiDiagnosisRemoteDataSource>(
    () => AiDiagnosisRemoteDataSourceImpl(client: http.Client()),
  );
  getIt.registerLazySingleton<AiDiagnosisRepository>(
    () => AiDiagnosisRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton(() => AnalyzeCropImage(getIt()));

  // BLoCs
  getIt.registerFactory(
    () => AuthBloc(
      loginUseCase: getIt(),
      registerUseCase: getIt(),
      logoutUseCase: getIt(),
    ),
  );

  getIt.registerFactory(
    () => CropsBloc(
      getUserCropsUseCase: getIt(),
      createCropUseCase: getIt(),
      deleteCropUseCase: getIt(),
    ),
  );

  // DashboardBloc recibe cropId como parámetro
  getIt.registerFactoryParam<DashboardBloc, String, void>(
    (cropId, _) => DashboardBloc(
      cropId: cropId,
      getSensorDataUseCase: getIt(),
      getActuatorStatusesUseCase: getIt(),
    ),
  );

  getIt.registerFactory(
    () => AiDiagnosisBloc(analyzeCropImage: getIt()),
  );
}
