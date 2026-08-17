import '../../domain/entities/ai_quiz_question_entity.dart';

class AiQuizQuestionModel extends AiQuizQuestionEntity {
  const AiQuizQuestionModel({
    required super.id,
    required super.content,
    required super.options,
    super.difficulty,
  });

  factory AiQuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return AiQuizQuestionModel(
      id: json['id'] as int,
      content: json['content'] as String? ?? '',
      options: (json['options'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      difficulty: json['difficulty'] as String?,
    );
  }
}