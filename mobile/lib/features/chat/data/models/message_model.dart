import '../../../../core/utils/date_time_utils.dart';
import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.senderName,
    super.content,
    super.type,
    required super.createdAt,
    super.editedAt,
    super.deletedAt,
  });

  factory MessageModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};
    return MessageModel(
      id: _readInt(map['id']),
      conversationId: _readInt(map['conversationId']),
      senderId: _readInt(map['senderId']),
      senderName: _readString(map['senderName']),
      content: _readNullableString(map['content']),
      type: _parseType(map['type']),
      createdAt: parseApiDateTime(map['createdAt']) ?? DateTime.now(),
      editedAt: parseApiDateTime(map['editedAt']),
      deletedAt: parseApiDateTime(map['deletedAt']),
    );
  }

  static ChatMessageType _parseType(Object? value) {
    final name = value?.toString().toLowerCase() ?? '';
    for (final type in ChatMessageType.values) {
      if (type.name == name) return type;
    }
    return ChatMessageType.text;
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _readString(Object? value) {
    return value?.toString() ?? '';
  }

  static String? _readNullableString(Object? value) {
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }
}
