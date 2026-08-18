import '../../../core/domain/entities/quiz_question_result_entity.dart';

class PracticeQuizSubmitResultEntity {
  final int score;
  final int total;
  final List<QuizQuestionResultEntity> results;

  const PracticeQuizSubmitResultEntity({
    required this.score,
    required this.total,
    required this.results,
  });

  double get percentage => total == 0 ? 0 : (score / total) * 100;
}