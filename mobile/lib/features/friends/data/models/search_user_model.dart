import '../../domain/entities/search_user_entity.dart';

class SearchUserModel extends SearchUserEntity {
  const SearchUserModel({
    required super.id,
    required super.name,
    super.username,
    super.picture,
    super.email,
  });

  factory SearchUserModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};
    final nestedUser = map['user'] is Map<String, dynamic>
        ? map['user'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return SearchUserModel(
      id: _readInt(nestedUser['id']),
      name: _readString(map['name']),
      username: _readNullableString(nestedUser['username']),
      picture: _readNullableString(nestedUser['picture']),
      email: _readNullableString(map['email']),
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
