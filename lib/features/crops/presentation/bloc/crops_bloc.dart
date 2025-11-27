import 'package:flutter_bloc/flutter_bloc.dart';
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

  CropsBloc({
    required this.getUserCropsUseCase,
    required this.createCropUseCase,
    required this.deleteCropUseCase,
  }) : super(CropsInitial()) {
    on<LoadCrops>(_onLoadCrops);
    on<RefreshCrops>(_onRefreshCrops);
    on<CreateCropRequested>(_onCreateCrop);
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
      plantType: event.plantType,
      location: event.location,
    );

    await result.fold((failure) async => emit(CropsError(failure.message)), (
      newCrop,
    ) async {
      // Recargar lista después de crear
      add(RefreshCrops());
    });
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
