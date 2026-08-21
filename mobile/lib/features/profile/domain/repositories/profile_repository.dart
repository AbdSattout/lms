import 'package:lms/features/profile/data/models/user_picture_model.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../entities/profile_entity.dart';
import '../usecases/update_profile_params.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();

  Future<String?> getCurrentAccountEmail();

  Future<ProfileEntity> updateProfile(UpdateProfileParams params);

  Future<UserPictureModel> updateProfilePicture(String imagePath);

  Future<void> requestAccountEmailOtp(String email);

  Future<String?> verifyAccountEmailOtp({
    required String email,
    required String otp,
  });
  Future<void> updateName(String name);
}
