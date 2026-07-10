
import 'package:lms/features/profile/domain/usecases/update_profile_params.dart';

import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {

  final ProfileRepository repository;

  UpdateProfileUseCase(
      this.repository,
      );

  Future<ProfileEntity> call(
      UpdateProfileParams params,
      ) {
    return repository.updateProfile(
      params,
    );
  }
}