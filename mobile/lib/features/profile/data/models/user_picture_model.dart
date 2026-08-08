class UserPictureModel {
  final int id;
  final String name;
  final String picture;

  UserPictureModel({
    required this.id,
    required this.name,
    required this.picture,
  });

  factory UserPictureModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};

    return UserPictureModel(
      id: _readInt(map["id"]),
      name: _readString(map["name"]),
      picture: _readString(map["picture"]),
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
}
