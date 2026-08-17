import '../../../core/data/models/quiz_question_result_model.dart';
import '../../domain/entities/random_quiz_submit_result_entity.dart';

class RandomQuizSubmitResultModel extends RandomQuizSubmitResultEntity {
  const RandomQuizSubmitResultModel({
    required super.attemptId,
    required super.score,
    required super.total,
    required super.results,
  });

  factory RandomQuizSubmitResultModel.fromJson(Map<String, dynamic> json) {
    return RandomQuizSubmitResultModel(
      attemptId: json['attemptId'] as int,
      score: json['score'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      results: (json['results'] as List<dynamic>? ?? [])
          .map((e) => QuizQuestionResultModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}