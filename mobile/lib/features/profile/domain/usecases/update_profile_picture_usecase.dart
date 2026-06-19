import '../repositories/profile_repository.dart';

class UpdateProfilePictureUseCase {
  final ProfileRepository repository;

  UpdateProfilePictureUseCase(this.repository);

  Future<void> call(String imagePath) {
    return repository.updateProfilePicture(imagePath);
  }
}