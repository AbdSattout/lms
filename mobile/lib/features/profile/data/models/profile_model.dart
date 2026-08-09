import '../../domain/entities/profile_entity.dart';
import '../../../auth/data/models/user_model.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.name,
    required super.user,
    super.email,
    super.phone,
    super.university,
  });

  factory ProfileModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};
    final user = UserModel.fromJson(map['user']);
    final email = _readNullableString(map['email']);
    final name = _firstNonEmpty([
      _readNullableString(map['name']),
      user.name,
      _nameFromEmail(email),
    ]);

    return ProfileModel(
      email: email,
      name: name,
      phone: _readNullableString(map['phone']),
      university: _readNullableString(map['university']),
      user: user,
    );
  }

  static String? _readNullableString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static String _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return '';
  }

  static String? _nameFromEmail(String? email) {
    if (email == null || email.isEmpty) return null;
    final atIndex = email.indexOf('@');
    if (atIndex <= 0) return email;
    return email.substring(0, atIndex);
  }
}
