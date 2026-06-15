import '../entities/profile_entity.dart';
import '../usecases/update_profile_params.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();

  Future<ProfileEntity> updateProfile(
      UpdateProfileParams params,
      );

  Future<ProfileEntity> updateProfilePicture(
      String imagePath,
      );
}