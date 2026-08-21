import 'package:dio/dio.dart';
import '../../../../core/databases/api/api_consumer.dart';
import '../../../../core/databases/api/end_points.dart';
import '../../domain/usecases/update_profile_params.dart';
import '../models/current_user_model.dart';
import '../models/profile_model.dart';
import '../models/user_picture_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();

  Future<CurrentUserModel> getCurrentUser();

  Future<ProfileModel> updateProfile(UpdateProfileParams params);

  Future<UserPictureModel> updateProfilePicture(String imagePath);

  Future<void> requestAccountEmailOtp(String email);

  Future<CurrentUserModel> updateName(String name);

  Future<CurrentUserModel> verifyAccountEmailOtp({
    required String email,
    required String otp,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiConsumer api;

  ProfileRemoteDataSourceImpl(this.api);

  @override
  Future<ProfileModel> getProfile() async {
    final response = await api.get(EndPoints.profile);

    return ProfileModel.fromJson(response);
  }

  @override
  Future<CurrentUserModel> getCurrentUser() async {
    final response = await api.get(EndPoints.currentUser);

    return CurrentUserModel.fromJson(response);
  }

  @override
  Future<ProfileModel> updateProfile(UpdateProfileParams params) async {
    print('📦 UPDATE PROFILE PARAMS: ${params.toJson()}');
    final response = await api.patch(EndPoints.profile, data: params.toJson());
    print('📦 UPDATE PROFILE RESPONSE: $response');
    return ProfileModel.fromJson(response);
  }

  @override
  Future<CurrentUserModel> updateName(String name) async {
    final response = await api.patch(
      EndPoints.currentUser,
      data: {'name': name},
    );
    return CurrentUserModel.fromJson(response);
  }

  @override
  Future<UserPictureModel> updateProfilePicture(String imagePath) async {
    final response = await api.patch(
      EndPoints.updateProfilePicture,
      data: {"image": await MultipartFile.fromFile(imagePath)},
      isFormData: true,
    );

    return UserPictureModel.fromJson(response);
  }

  @override
  Future<void> requestAccountEmailOtp(String email) async {
    await api.post(EndPoints.requestAccountEmailOtp, data: {'email': email});
  }

  @override
  Future<CurrentUserModel> verifyAccountEmailOtp({
    required String email,
    required String otp,
  }) async {
    final response = await api.post(
      EndPoints.verifyAccountEmailOtp,
      data: {'email': email, 'otp': otp},
    );

    return CurrentUserModel.fromJson(response);
  }
}
