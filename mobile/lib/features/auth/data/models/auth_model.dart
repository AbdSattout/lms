import 'package:lms/features/auth/data/models/user_model.dart';
import '../../domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  const AuthModel({required super.token, required super.user});

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      token: json['token'] ?? '',
      user: json['user'] != null 
          ? UserModel.fromJson(json['user']) 
          : const UserModel(id: 0, name: '', picture: '', idTelegram: ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': (user as UserModel).toJson(),
    };
  }
}