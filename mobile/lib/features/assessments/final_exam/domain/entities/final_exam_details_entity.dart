import '../../../core/domain/entities/quiz_question_entity.dart';

class FinalExamDetailsEntity {
  final int quizId;
  final int courseId;
  final String? difficulty;
  final List<QuizQuestionEntity> questions;

  const FinalExamDetailsEntity({
    required this.quizId,
    required this.courseId,
    this.difficulty,
    required this.questions,
  });
}