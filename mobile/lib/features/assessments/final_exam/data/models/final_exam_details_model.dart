import '../../../core/data/models/quiz_question_model.dart';
import '../../domain/entities/final_exam_details_entity.dart';

class FinalExamDetailsModel extends FinalExamDetailsEntity {
  const FinalExamDetailsModel({
    required super.quizId,
    required super.courseId,
    super.difficulty,
    required super.questions,
  });

  factory FinalExamDetailsModel.fromJson(Map<String, dynamic> json) {
    return FinalExamDetailsModel(
      quizId: json['quizId'] as int,
      courseId: json['courseId'] as int,
      difficulty: json['difficulty'] as String?,
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((e) => QuizQuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}