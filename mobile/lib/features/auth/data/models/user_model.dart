import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  static const empty = UserModel(id: 0, name: '', picture: '', idTelegram: '');

  const UserModel({
    required super.id,
    required super.name,
    required super.picture,
    required super.idTelegram,
  });

  factory UserModel.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      return empty;
    }

    return UserModel(
      id: _readInt(json['id']),
      name: _readString(json['name']),
      picture: _readString(json['picture']),
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

  static int _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _readString(Object? value) {
    return value?.toString().trim() ?? '';
  }
}
