import '../../../core/domain/entities/quiz_question_entity.dart';

class PracticeQuizDetailsEntity {
  final int id;
  final String title;
  final String description;
  final int courseId;
  final String? difficulty;
  final List<QuizQuestionEntity> questions;

  const PracticeQuizDetailsEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    this.difficulty,
    required this.questions,
  });
}