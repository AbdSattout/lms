import 'package:lms/core/errors/error_model.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/features/auth/data/models/user_model.dart';
import '../../domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  const AuthModel({required super.token, required super.user});

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final token = json['token'];
    if (token == null) {
      throw ServerException(
        ErrorModel(
          status: 0,
          errorMessage: 'رمز الدخول مفقود من استجابة السيرفر',
        ),
      );
    }
    return AuthModel(
      token: token,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'])
          : const UserModel(id: 0, name: '', picture: '', idTelegram: ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'user': (user as UserModel).toJson()};
  }
}
