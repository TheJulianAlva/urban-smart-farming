import 'package:equatable/equatable.dart';

/// Eventos del BLoC de cultivos
abstract class CropsEvent extends Equatable {
  const CropsEvent();

  @override
  List<Object?> get props => [];
}

class LoadCrops extends CropsEvent {}

class RefreshCrops extends CropsEvent {}

class CreateCropRequested extends CropsEvent {
  final String name;
  final String plantType;
  final String location;

  const CreateCropRequested({
    required this.name,
    required this.plantType,
    required this.location,
  });

  @override
  List<Object?> get props => [name, plantType, location];
}

class DeleteCropRequested extends CropsEvent {
  final String cropId;

  const DeleteCropRequested(this.cropId);

  @override
  List<Object?> get props => [cropId];
}
