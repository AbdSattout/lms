import '../../../core/data/models/quiz_question_model.dart';
import '../../domain/entities/practice_quiz_details_entity.dart';

class PracticeQuizDetailsModel extends PracticeQuizDetailsEntity {
  const PracticeQuizDetailsModel({
    required super.id,
    required super.title,
    required super.description,
    required super.courseId,
    super.difficulty,
    required super.questions,
  });

  factory PracticeQuizDetailsModel.fromJson(Map<String, dynamic> json) {
    return PracticeQuizDetailsModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      courseId: json['courseId'] as int? ?? 0,
      difficulty: json['difficulty'] as String?,
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((e) => QuizQuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}