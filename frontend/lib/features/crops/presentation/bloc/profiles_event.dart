import 'package:equatable/equatable.dart';

abstract class ProfilesEvent extends Equatable {
  const ProfilesEvent();
  @override
  List<Object?> get props => [];
}

class LoadUserProfiles extends ProfilesEvent {
  const LoadUserProfiles();
}
