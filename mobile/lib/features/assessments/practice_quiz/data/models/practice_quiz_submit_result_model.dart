import '../../../core/data/models/quiz_question_result_model.dart';
import '../../domain/entities/practice_quiz_submit_result_entity.dart';

class PracticeQuizSubmitResultModel extends PracticeQuizSubmitResultEntity {
  const PracticeQuizSubmitResultModel({
    required super.score,
    required super.total,
    required super.results,
  });

  factory PracticeQuizSubmitResultModel.fromJson(Map<String, dynamic> json) {
    return PracticeQuizSubmitResultModel(
      score: json['score'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      results: (json['results'] as List<dynamic>? ?? [])
          .map((e) => QuizQuestionResultModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}