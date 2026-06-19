import '../../domain/entities/profile_entity.dart';
import '../../../auth/data/models/user_model.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.name,
    required super.user,
    super.email,
    super.phone,
    super.university,
  });

  factory ProfileModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return ProfileModel(
      email: json['email'],
      name: json['name'] ?? '',
      phone: json['phone'],
      university: json['university'],
      user: UserModel.fromJson(
        json['user'],
      ),
    );
  }
}