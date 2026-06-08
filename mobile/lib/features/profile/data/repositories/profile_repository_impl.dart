import 'package:lms/features/profile/data/models/user_picture_model.dart';

import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
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
  Future<UserPictureModel> updateProfilePicture(
      String imagePath,
      ) {
    return remote.updateProfilePicture(
      imagePath,
    );
  }
}