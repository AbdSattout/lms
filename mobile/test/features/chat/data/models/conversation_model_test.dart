import 'package:flutter_test/flutter_test.dart';
import 'package:lms/features/chat/data/models/conversation_model.dart';
import 'package:lms/features/chat/domain/entities/conversation_entity.dart';

void main() {
  test('parses a direct conversation with nested user objects', () {
    final conversation = ConversationModel.fromJson({
      'id': 6,
      'type': 'DIRECT',
      'courseId': null,
      'directUserOne': {
        'id': 2,
        'name': 'Abodeh Alshammaa',
        'username': null,
        'picture': 'https://example.com/a.png',
      },
      'directUserTwo': {
        'id': 14,
        'name': 'Ali Hamdy',
        'username': null,
        'picture': 'https://example.com/b.png',
      },
      'lastMessagePreview': 'helk',
      'lastMessageAt': '2026-08-20T15:43:14.117696Z',
    });

    expect(conversation.id, 6);
    expect(conversation.type, ConversationType.direct);
    expect(conversation.directUserOneId, 2);
    expect(conversation.directUserTwoId, 14);
    expect(conversation.directUserOne?.name, 'Abodeh Alshammaa');
    expect(conversation.directUserTwo?.name, 'Ali Hamdy');
    expect(conversation.otherUserId(2), 14);
    expect(conversation.otherUserId(14), 2);
    expect(conversation.otherUser(2)?.name, 'Ali Hamdy');
    expect(conversation.otherUser(14)?.name, 'Abodeh Alshammaa');
    expect(conversation.lastMessagePreview, 'helk');
    expect(conversation.lastMessageAt, isNotNull);
  });

  test('parses a course conversation without messages', () {
    final conversation = ConversationModel.fromJson({
      'id': 20,
      'type': 'COURSE',
      'courseId': 33,
      'directUserOne': null,
      'directUserTwo': null,
      'lastMessagePreview': null,
      'lastMessageAt': null,
    });

    expect(conversation.id, 20);
    expect(conversation.type, ConversationType.course);
    expect(conversation.courseId, 33);
    expect(conversation.directUserOneId, isNull);
    expect(conversation.directUserTwoId, isNull);
    expect(conversation.lastMessagePreview, isNull);
    expect(conversation.lastMessageAt, isNull);
    expect(conversation.otherUserId(5), isNull);
  });

  test('falls back to legacy user id fields', () {
    final conversation = ConversationModel.fromJson({
      'id': 7,
      'type': 'DIRECT',
      'directUserOneId': 5,
      'directUserTwoId': 9,
    });

    expect(conversation.directUserOneId, 5);
    expect(conversation.directUserTwoId, 9);
    expect(conversation.directUserOne, isNull);
    expect(conversation.otherUserId(5), 9);
  });
}