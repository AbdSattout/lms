import '../../../core/data/models/quiz_question_model.dart';
import '../../domain/entities/random_quiz_session_entity.dart';

class RandomQuizSessionModel extends RandomQuizSessionEntity {
  const RandomQuizSessionModel({
    required super.attemptId,
    required super.difficulty,
    required super.questions,
  });

  factory RandomQuizSessionModel.fromJson(Map<String, dynamic> json) {
    return RandomQuizSessionModel(
      attemptId: json['attemptId'] as int,
      difficulty: json['difficulty'] as String? ?? 'MEDIUM',
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((e) => QuizQuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}