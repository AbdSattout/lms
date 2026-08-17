import 'ai_quiz_question_result_entity.dart';

class AiQuizSubmitResultEntity {
  final int attemptId;
  final int score;
  final int total;
  final List<AiQuizQuestionResultEntity> results;

  const AiQuizSubmitResultEntity({
    required this.attemptId,
    required this.score,
    required this.total,
    required this.results,
  });

  double get percentage => total == 0 ? 0 : (score / total) * 100;
}