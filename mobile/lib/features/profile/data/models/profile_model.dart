import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.phone,
    required super.name,
    required super.email,
    required super.university,
  });

  factory ProfileModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return ProfileModel(
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      university: json['university'],
    );
  }
}