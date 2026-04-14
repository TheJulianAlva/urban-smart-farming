import 'package:equatable/equatable.dart';
import 'package:urban_smart_farming/features/crops/domain/entities/crop_entity.dart';

/// Estados del BLoC de cultivos
abstract class CropsState extends Equatable {
  const CropsState();

  @override
  List<Object?> get props => [];
}

class CropsInitial extends CropsState {}

class CropsLoading extends CropsState {}

class CropsLoaded extends CropsState {
  final List<CropEntity> crops;

  const CropsLoaded(this.crops);

  @override
  List<Object?> get props => [crops];
}

class CropsError extends CropsState {
  final String message;

  const CropsError(this.message);

  @override
  List<Object?> get props => [message];
}
