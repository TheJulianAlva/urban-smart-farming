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

/// Evento para agregar cultivo desde el wizard
class AddCrop extends CropsEvent {
  final String name;
  final String location;
  final dynamic profile; // CropProfile
  final String? hardwareId;

  const AddCrop({
    required this.name,
    required this.location,
    required this.profile,
    this.hardwareId,
  });

  @override
  List<Object?> get props => [name, location, profile, hardwareId];
}

class DeleteCropRequested extends CropsEvent {
  final String cropId;

  const DeleteCropRequested(this.cropId);

  @override
  List<Object?> get props => [cropId];
}
