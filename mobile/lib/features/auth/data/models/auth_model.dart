import '../../domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  AuthModel({required super.idToken});

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      idToken: json['idToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idToken': idToken,
    };
  }
}