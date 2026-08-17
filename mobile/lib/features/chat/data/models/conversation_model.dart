import '../../../../core/utils/date_time_utils.dart';
import '../../domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.type,
    super.courseId,
    super.directUserOneId,
    super.directUserTwoId,
    super.lastMessagePreview,
    super.lastMessageAt,
  });

  factory ConversationModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};
    return ConversationModel(
      id: _readInt(map['id']),
      type: _parseType(map['type']),
      courseId: _readNullableInt(map['courseId']),
      directUserOneId: _readNullableInt(map['directUserOneId']),
      directUserTwoId: _readNullableInt(map['directUserTwoId']),
      lastMessagePreview: _readNullableString(map['lastMessagePreview']),
      lastMessageAt: parseApiDateTime(map['lastMessageAt']),
    );
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
