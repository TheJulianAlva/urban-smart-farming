import 'package:dartz/dartz.dart';
import 'package:urban_smart_farming/core/utils/failures.dart' show Failure;
import 'package:urban_smart_farming/features/crops/domain/entities/crop_profile.dart';
import 'package:urban_smart_farming/features/crops/domain/repositories/crop_repository.dart';

class GetUserProfilesUseCase {
  final CropRepository repository;

  GetUserProfilesUseCase(this.repository);

  Future<Either<Failure, List<PlantProfile>>> call() {
    return repository.getUserProfiles();
  }
}
