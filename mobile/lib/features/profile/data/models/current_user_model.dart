class CurrentUserModel {
  final int id;
  final String name;
  final String username;
  final String picture;
  final String? email;

  const CurrentUserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.picture,
    this.email,
  });

  factory CurrentUserModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};

    return CurrentUserModel(
      id: _readInt(map['id']),
      name: _readString(map['name']),
      username: _readString(map['username']),
      picture: _readString(map['picture']),
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
