import 'package:lms/features/profile/data/models/user_picture_model.dart';

import '../entities/profile_entity.dart';
import '../usecases/update_profile_params.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();

  Future<ProfileEntity> updateProfile(
      UpdateProfileParams params,
      );

  Future<UserPictureModel> updateProfilePicture(
      String imagePath,
      );
}