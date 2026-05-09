import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urban_smart_farming/features/crops/domain/usecases/get_user_profiles_use_case.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/profiles_event.dart';
import 'package:urban_smart_farming/features/crops/presentation/bloc/profiles_state.dart';

class ProfilesBloc extends Bloc<ProfilesEvent, ProfilesState> {
  final GetUserProfilesUseCase getUserProfilesUseCase;

  ProfilesBloc({required this.getUserProfilesUseCase})
      : super(ProfilesInitial()) {
    on<LoadUserProfiles>(_onLoadUserProfiles);
  }

  Future<void> _onLoadUserProfiles(
    LoadUserProfiles event,
    Emitter<ProfilesState> emit,
  ) async {
    emit(ProfilesLoading());
    final result = await getUserProfilesUseCase();
    result.fold(
      (failure) => emit(ProfilesError(failure.message)),
      (profiles) => emit(ProfilesLoaded(profiles)),
    );
  }
}
