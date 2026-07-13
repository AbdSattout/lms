import 'package:dio/dio.dart';
import '../../../../core/databases/api/api_consumer.dart';
import '../../../../core/databases/api/end_points.dart';
import '../../domain/usecases/update_profile_params.dart';
import '../models/profile_model.dart';
import '../models/user_picture_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();

  Future<ProfileModel> updateProfile(
      UpdateProfileParams params,
      );

  Future<UserPictureModel> updateProfilePicture(
      String imagePath,
      );
}
class ProfileRemoteDataSourceImpl
    implements ProfileRemoteDataSource {

  final ApiConsumer api;

  ProfileRemoteDataSourceImpl(this.api);

  @override
  Future<ProfileModel> getProfile() async {

    final response = await api.get(
      EndPoints.profile,
    );

    return ProfileModel.fromJson(response);
  }

  @override
  Future<ProfileModel> updateProfile(
      UpdateProfileParams params,
      ) async {
    final response = await api.patch(
      EndPoints.profile,
      data: params.toJson(),
    );

    return ProfileModel.fromJson(
      response,
    );
  }
  @override
  Future<UserPictureModel> updateProfilePicture(
      String imagePath,
      ) async {
    final response = await api.patch(
      EndPoints.updateProfilePicture,
      data: {
        "image": await MultipartFile.fromFile(
          imagePath,
        ),
      },
      isFormData: true,
    );

    return UserPictureModel.fromJson(
      response,
    );
  }
}