import '../../domain/entities/friend_user_entity.dart';

class FriendUserModel extends FriendUserEntity {
  const FriendUserModel({
    required super.id,
    required super.name,
    super.username,
    super.picture,
  });

  factory FriendUserModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};

    return FriendUserModel(
      id: _readInt(map['id']),
      name: _readString(map['name']),
      username: _readNullableString(map['username']),
      picture: _readNullableString(map['picture']),
    );
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _readString(Object? value) {
    return value?.toString().trim() ?? '';
  }

  static String? _readNullableString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
