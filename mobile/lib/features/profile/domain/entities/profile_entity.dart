import '../../../auth/domain/entities/user_entity.dart';

class ProfileEntity {
  final String? email;
  final String? phone;
  final String name;
  final String? university;
  final UserEntity user;

  const ProfileEntity({
    required this.name,
    required this.user,
    this.email,
    this.phone,
    this.university,
  });
}