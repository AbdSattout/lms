import '../../domain/entities/ai_quiz_session_entity.dart';
import 'ai_quiz_question_model.dart';

class AiQuizSessionModel extends AiQuizSessionEntity {
  const AiQuizSessionModel({
    required super.attemptId,
    super.difficulty,
    required super.questions,
  });

  factory AiQuizSessionModel.fromJson(Map<String, dynamic> json) {
    return AiQuizSessionModel(
      attemptId: json['attemptId'] as int,
      difficulty: json['difficulty'] as String?,
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((e) => AiQuizQuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}