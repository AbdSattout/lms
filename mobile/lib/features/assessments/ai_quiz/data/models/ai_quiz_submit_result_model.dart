import '../../domain/entities/ai_quiz_submit_result_entity.dart';
import 'ai_quiz_question_result_model.dart';

class AiQuizSubmitResultModel extends AiQuizSubmitResultEntity {
  const AiQuizSubmitResultModel({
    required super.attemptId,
    required super.score,
    required super.total,
    required super.results,
  });

  factory AiQuizSubmitResultModel.fromJson(Map<String, dynamic> json) {
    return AiQuizSubmitResultModel(
      attemptId: json['attemptId'] as int,
      score: json['score'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      results: (json['results'] as List<dynamic>? ?? [])
          .map((e) => AiQuizQuestionResultModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}