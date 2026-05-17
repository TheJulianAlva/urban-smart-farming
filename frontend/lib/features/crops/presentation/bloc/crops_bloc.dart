import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urban_smart_farming/features/crops/domain/repositories/crop_repository.dart';
import 'package:urban_smart_farming/features/crops/domain/usecases/get_user_crops_use_case.dart';
import 'package:urban_smart_farming/features/crops/domain/usecases/create_crop_use_case.dart';
import 'package:urban_smart_farming/features/crops/domain/usecases/delete_crop_use_case.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/crops_event.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/crops_state.dart';

/// BLoC para gestión de cultivos
class CropsBloc extends Bloc<CropsEvent, CropsState> {
  final GetUserCropsUseCase getUserCropsUseCase;
  final CreateCropUseCase createCropUseCase;
  final DeleteCropUseCase deleteCropUseCase;
  final CropRepository cropRepository;

  CropsBloc({
    required this.getUserCropsUseCase,
    required this.createCropUseCase,
    required this.deleteCropUseCase,
    required this.cropRepository,
  }) : super(CropsInitial()) {
    on<LoadCrops>(_onLoadCrops);
    on<RefreshCrops>(_onRefreshCrops);
    on<CreateCropRequested>(_onCreateCrop);
    on<AddCrop>(_onAddCrop);
    on<DeleteCropRequested>(_onDeleteCrop);
  }

  Future<void> _onLoadCrops(LoadCrops event, Emitter<CropsState> emit) async {
    emit(CropsLoading());

    final result = await getUserCropsUseCase();

    result.fold(
      (failure) => emit(CropsError(failure.message)),
      (crops) => emit(CropsLoaded(crops)),
    );
  }

  Future<void> _onRefreshCrops(
    RefreshCrops event,
    Emitter<CropsState> emit,
  ) async {
    // No mostrar loading en refresh
    final result = await getUserCropsUseCase();

    result.fold(
      (failure) => emit(CropsError(failure.message)),
      (crops) => emit(CropsLoaded(crops)),
    );
  }

  Future<void> _onCreateCrop(
    CreateCropRequested event,
    Emitter<CropsState> emit,
  ) async {
    final result = await createCropUseCase(
      name: event.name,
      profileId: event.plantType, // plantType contiene el id del perfil
      location: event.location,
    );

    await result.fold((failure) async => emit(CropsError(failure.message)), (
      newCrop,
    ) async {
      // Recargar lista después de crear
      add(RefreshCrops());
    });
  }

  Future<void> _onAddCrop(AddCrop event, Emitter<CropsState> emit) async {
    final result = await createCropUseCase(
      name: event.name,
      profileId: event.profile.id, // UUID de Supabase CropProfile
      location: event.location,
    );

    await result.fold(
      (failure) async => emit(CropsError(failure.message)),
      (newCrop) async {
        // Si el usuario seleccionó hardware, registrarlo vinculado al cultivo
        final hardwareId = event.hardwareId;
        if (hardwareId != null && hardwareId.isNotEmpty) {
          final deviceResult = await cropRepository.registerDevice(
            cropId: newCrop.id,
            macAddress: hardwareId,
          );
          deviceResult.fold(
            (failure) {
              // El cultivo YA fue creado — no hacer rollback.
              // Emitir advertencia para que la UI muestre un SnackBar.
              emit(
                const CropsCreatedWithDeviceError(
                  'Cultivo creado, pero no se pudo vincular el hardware. '
                  'Puedes vincularlo más tarde.',
                ),
              );
              add(RefreshCrops());
            },
            (_) => add(RefreshCrops()),
          );
        } else {
          add(RefreshCrops());
        }
      },
    );
  }

  Future<void> _onDeleteCrop(
    DeleteCropRequested event,
    Emitter<CropsState> emit,
  ) async {
    final result = await deleteCropUseCase(event.cropId);

    await result.fold((failure) async => emit(CropsError(failure.message)), (
      _,
    ) async {
      // Recargar lista después de eliminar
      add(RefreshCrops());
    });
  }
}
