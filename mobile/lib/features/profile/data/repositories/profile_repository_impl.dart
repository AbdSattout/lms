import 'package:lms/features/profile/data/models/profile_model.dart';
import 'package:lms/features/profile/data/models/user_picture_model.dart';

import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/update_profile_params.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl
    implements ProfileRepository {

  final ProfileRemoteDataSource remote;

  ProfileRepositoryImpl(this.remote);

  @override
  Future<ProfileEntity> getProfile() {
    return remote.getProfile();
  }

  @override
  Future<ProfileEntity> updateProfile(
      UpdateProfileParams params,
      ) {
    return remote.updateProfile(
      params,
    );
  }
  @override
  Future<ProfileModel> updateProfilePicture(
      String imagePath,
      ) {
    return remote.updateProfilePicture(
      imagePath,
    );
  }
}