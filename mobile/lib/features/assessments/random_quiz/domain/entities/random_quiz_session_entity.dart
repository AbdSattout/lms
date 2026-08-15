import '../../../core/domain/entities/quiz_question_entity.dart';

class RandomQuizSessionEntity {
  final int attemptId;
  final String difficulty;
  final List<QuizQuestionEntity> questions;

  const RandomQuizSessionEntity({
    required this.attemptId,
    required this.difficulty,
    required this.questions,
  });
}