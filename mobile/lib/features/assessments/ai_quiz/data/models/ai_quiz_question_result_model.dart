import '../../domain/entities/ai_quiz_question_result_entity.dart';

class AiQuizQuestionResultModel extends AiQuizQuestionResultEntity {
  const AiQuizQuestionResultModel({
    required super.questionId,
    required super.content,
    required super.options,
    super.selectedAnswerIndex,
    required super.correctAnswerIndex,
    required super.correct,
  });

  factory AiQuizQuestionResultModel.fromJson(Map<String, dynamic> json) {
    return AiQuizQuestionResultModel(
      questionId: json['questionId'] as int,
      content: json['content'] as String? ?? '',
      options: (json['options'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      selectedAnswerIndex: json['selectedAnswerIndex'] as int?,
      correctAnswerIndex: json['correctAnswerIndex'] as int? ?? 0,
      correct: json['correct'] as bool? ?? false,
    );
  }
}