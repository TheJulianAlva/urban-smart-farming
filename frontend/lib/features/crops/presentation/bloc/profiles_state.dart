import 'package:equatable/equatable.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/crop_profile.dart';

abstract class ProfilesState extends Equatable {
  const ProfilesState();
  @override
  List<Object?> get props => [];
}

class ProfilesInitial extends ProfilesState {}

class ProfilesLoading extends ProfilesState {}

class ProfilesLoaded extends ProfilesState {
  final List<PlantProfile> userProfiles;

  const ProfilesLoaded(this.userProfiles);

  @override
  List<Object?> get props => [userProfiles];
}

class ProfilesError extends ProfilesState {
  final String message;

  const ProfilesError(this.message);

  @override
  List<Object?> get props => [message];
}
