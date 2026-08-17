import 'package:flutter_test/flutter_test.dart';
import 'package:lms/features/chat/data/models/message_model.dart';
import 'package:lms/features/chat/domain/entities/message_entity.dart';

void main() {
  test('parses a text message with Instant createdAt and LocalDateTime edits',
      () {
    final message = MessageModel.fromJson({
      'id': 1,
      'conversationId': 12,
      'senderId': 5,
      'senderName': 'اسم المستخدم',
      'content': 'السلام عليكم',
      'type': 'TEXT',
      'createdAt': '2026-08-16T10:00:00Z',
      'editedAt': '2026-08-16T10:01:00',
      'deletedAt': null,
    });

    expect(message.id, 1);
    expect(message.conversationId, 12);
    expect(message.senderId, 5);
    expect(message.senderName, 'اسم المستخدم');
    expect(message.content, 'السلام عليكم');
    expect(message.type, ChatMessageType.text);
    expect(
      message.createdAt,
      DateTime.utc(2026, 8, 16, 10).toLocal(),
    );
    expect(
      message.editedAt,
      DateTime.utc(2026, 8, 16, 10, 1).toLocal(),
    );
    expect(message.deletedAt, isNull);
    expect(message.isDeleted, isFalse);
    expect(message.isMine(5), isTrue);
    expect(message.isMine(9), isFalse);
  });

  test('parses a deleted message with null content', () {
    final message = MessageModel.fromJson({
      'id': 2,
      'conversationId': 12,
      'senderId': 9,
      'senderName': 'طرف آخر',
      'content': null,
      'type': 'TEXT',
      'createdAt': '2026-08-16T11:00:00Z',
      'editedAt': null,
      'deletedAt': '2026-08-16T11:05:00Z',
    });

    expect(message.content, isNull);
    expect(message.isDeleted, isTrue);
    expect(
      message.deletedAt,
      DateTime.utc(2026, 8, 16, 11, 5).toLocal(),
    );
  });

  test('parses IMAGE and unknown types defensively', () {
    final image = MessageModel.fromJson({
      'id': 3,
      'conversationId': 12,
      'senderId': 5,
      'senderName': 'اسم المستخدم',
      'content': 'photo',
      'type': 'IMAGE',
      'createdAt': '2026-08-16T12:00:00Z',
      'editedAt': null,
      'deletedAt': null,
    });
    expect(image.type, ChatMessageType.image);

    final unknown = MessageModel.fromJson({
      'id': 4,
      'conversationId': 12,
      'senderId': 5,
      'senderName': 'اسم المستخدم',
      'content': 'x',
      'type': 'VOICE',
      'createdAt': '2026-08-16T12:00:00Z',
      'editedAt': null,
      'deletedAt': null,
    });
    expect(unknown.type, ChatMessageType.text);
  });

  test('copyWith clears deletedAt when requested', () {
    final message = MessageModel.fromJson({
      'id': 5,
      'conversationId': 12,
      'senderId': 5,
      'senderName': 'اسم المستخدم',
      'content': null,
      'type': 'TEXT',
      'createdAt': '2026-08-16T12:00:00Z',
      'editedAt': null,
      'deletedAt': '2026-08-16T12:30:00Z',
    });

    final restored = message.copyWith(
      content: 'تمت الاستعادة',
      clearDeletedAt: true,
    );
    expect(restored.isDeleted, isFalse);
    expect(restored.content, 'تمت الاستعادة');
  });
}