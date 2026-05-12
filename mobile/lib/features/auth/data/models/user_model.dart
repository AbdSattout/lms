import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.picture,
    required super.idTelegram,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // استخدام ?? لإعطاء قيم افتراضية ومنع خطأ الـ Null
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      picture: json['picture'] ?? '',
      // استخدام .toString() لضمان تحويل أي قيمة قادمة لـ String
      idTelegram: json['idTelegram']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'picture': picture,
      'idTelegram': idTelegram,
    };
  }
}