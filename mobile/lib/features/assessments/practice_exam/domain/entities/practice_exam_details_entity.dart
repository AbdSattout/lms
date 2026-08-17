import '../../../core/domain/entities/quiz_question_entity.dart';

class PracticeExamDetailsEntity {
  final int id;
  final String title;
  final String description;
  final int? timeLimitMinutes;
  final int attemptId;
  final DateTime? startedAt;
  final DateTime? expiresAt;
  final DateTime? serverTime;
  final int courseId;
  final String? difficulty;
  final List<QuizQuestionEntity> questions;

  const PracticeExamDetailsEntity({
    required this.id,
    required this.title,
    required this.description,
    this.timeLimitMinutes,
    required this.attemptId,
    this.startedAt,
    this.expiresAt,
    this.serverTime,
    required this.courseId,
    this.difficulty,
    required this.questions,
  });
}