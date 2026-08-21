import '../../../../core/utils/date_time_utils.dart';
import '../../../friends/data/models/friend_user_model.dart';
import '../../../friends/domain/entities/friend_user_entity.dart';
import '../../domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.type,
    super.courseId,
    super.directUserOneId,
    super.directUserTwoId,
    super.directUserOne,
    super.directUserTwo,
    super.lastMessagePreview,
    super.lastMessageAt,
  });

  factory ConversationModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};
    final directUserOne = _parseUser(map['directUserOne']);
    final directUserTwo = _parseUser(map['directUserTwo']);
    return ConversationModel(
      id: _readInt(map['id']),
      type: _parseType(map['type']),
      courseId: _readNullableInt(map['courseId']),
      directUserOneId:
          directUserOne?.id ?? _readNullableInt(map['directUserOneId']),
      directUserTwoId:
          directUserTwo?.id ?? _readNullableInt(map['directUserTwoId']),
      directUserOne: directUserOne,
      directUserTwo: directUserTwo,
      lastMessagePreview: _readNullableString(map['lastMessagePreview']),
      lastMessageAt: parseApiDateTime(map['lastMessageAt']),
    );
  }

  static FriendUserEntity? _parseUser(Object? value) {
    if (value is Map<String, dynamic> && value['id'] != null) {
      return FriendUserModel.fromJson(value);
    }
    return null;
  }

  static ConversationType _parseType(Object? value) {
    final name = value?.toString().toLowerCase() ?? '';
    for (final type in ConversationType.values) {
      if (type.name == name) return type;
    }
    return ConversationType.direct;
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _readNullableInt(Object? value) {
    if (value == null) return null;
    return _readInt(value);
  }

  static String? _readNullableString(Object? value) {
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }
}