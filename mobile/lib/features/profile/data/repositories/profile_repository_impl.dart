import 'package:lms/features/profile/data/models/user_picture_model.dart';

import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/update_profile_params.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remote;

  ProfileRepositoryImpl(this.remote);

  @override
  Future<ProfileEntity> getProfile() {
    return remote.getProfile();
  }

  @override
  Future<String?> getCurrentAccountEmail() async {
    final user = await remote.getCurrentUser();
    return user.email;
  }

  @override
  Future<ProfileEntity> updateProfile(UpdateProfileParams params) {
    return remote.updateProfile(params);
  }

  @override
  Future<void> updateName(String name) async {
    await remote.updateName(name);
  }

  @override
  Future<UserPictureModel> updateProfilePicture(String imagePath) {
    return remote.updateProfilePicture(imagePath);
  }

  @override
  Future<void> requestAccountEmailOtp(String email) {
    return remote.requestAccountEmailOtp(email);
  }

  @override
  Future<String?> verifyAccountEmailOtp({
    required String email,
    required String otp,
  }) async {
    final user = await remote.verifyAccountEmailOtp(email: email, otp: otp);
    return user.email;
  }
}
