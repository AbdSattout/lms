import 'package:flutter_test/flutter_test.dart';
import 'package:lms/features/chat/data/models/conversation_model.dart';
import 'package:lms/features/chat/domain/entities/conversation_entity.dart';

void main() {
  test('parses a direct conversation with preview and Instant timestamp', () {
    final conversation = ConversationModel.fromJson({
      'id': 12,
      'type': 'DIRECT',
      'courseId': null,
      'directUserOneId': 5,
      'directUserTwoId': 9,
      'lastMessagePreview': 'مرحبا',
      'lastMessageAt': '2026-08-16T10:00:00Z',
    });

    expect(conversation.id, 12);
    expect(conversation.type, ConversationType.direct);
    expect(conversation.courseId, isNull);
    expect(conversation.directUserOneId, 5);
    expect(conversation.directUserTwoId, 9);
    expect(conversation.lastMessagePreview, 'مرحبا');
    expect(
      conversation.lastMessageAt,
      DateTime.utc(2026, 8, 16, 10).toLocal(),
    );
    expect(conversation.otherUserId(5), 9);
    expect(conversation.otherUserId(9), 5);
  });

  test('parses a course conversation without messages', () {
    final conversation = ConversationModel.fromJson({
      'id': 20,
      'type': 'COURSE',
      'courseId': 33,
      'directUserOneId': null,
      'directUserTwoId': null,
      'lastMessagePreview': null,
      'lastMessageAt': null,
    });

    expect(conversation.id, 20);
    expect(conversation.type, ConversationType.course);
    expect(conversation.courseId, 33);
    expect(conversation.lastMessagePreview, isNull);
    expect(conversation.lastMessageAt, isNull);
    expect(conversation.otherUserId(5), isNull);
  });

  test('falls back to direct type and empty values for unknown shapes', () {
    final conversation = ConversationModel.fromJson({
      'id': '7',
      'type': 'GROUP',
      'directUserOneId': '1',
    });

    expect(conversation.id, 7);
    expect(conversation.type, ConversationType.direct);
    expect(conversation.directUserOneId, 1);
    expect(conversation.directUserTwoId, isNull);
    expect(conversation.lastMessageAt, isNull);
  });
}