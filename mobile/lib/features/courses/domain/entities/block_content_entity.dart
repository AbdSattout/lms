import 'course_entity.dart' show RewardEntity;

class BlockQuestionEntity {
  final int id;
  final String content;
  final List<String> options;
  final String difficulty;

  const BlockQuestionEntity({
    required this.id,
    required this.content,
    required this.options,
    required this.difficulty,
  });
}

class BlockContentEntity {
  final int id;
  final String title;
  final String content;
  final int position;
  final BlockQuestionEntity? question;

  const BlockContentEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.position,
    this.question,
  });
}

class BlockAnswerResultEntity {
  final String nextType;
  final int? nextBlockId;
  final int? nextLessonId;
  final int? nextChapterId;
  final int? quizId;
  final String message;
  final List<RewardEntity> rewards;

  const BlockAnswerResultEntity({
    required this.nextType,
    this.nextBlockId,
    this.nextLessonId,
    this.nextChapterId,
    this.quizId,
    required this.message,
    this.rewards = const [],
  });

  bool get isCorrect => nextType != 'INCORRECT';
}
