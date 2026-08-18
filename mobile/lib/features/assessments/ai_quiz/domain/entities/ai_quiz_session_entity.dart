import 'ai_quiz_question_entity.dart';

class AiQuizSessionEntity {
  final int attemptId;
  final String? difficulty;
  final List<AiQuizQuestionEntity> questions;

  const AiQuizSessionEntity({
    required this.attemptId,
    required this.difficulty,
    required this.questions,
  });
}