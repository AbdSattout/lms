import '../../../core/data/models/quiz_question_model.dart';
import '../../domain/entities/practice_exam_details_entity.dart';

class PracticeExamDetailsModel extends PracticeExamDetailsEntity {
  const PracticeExamDetailsModel({
    required super.id,
    required super.title,
    required super.description,
    super.timeLimitMinutes,
    required super.attemptId,
    super.startedAt,
    super.expiresAt,
    super.serverTime,
    required super.courseId,
    super.difficulty,
    required super.questions,
  });

  factory PracticeExamDetailsModel.fromJson(Map<String, dynamic> json) {
    return PracticeExamDetailsModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      timeLimitMinutes: json['timeLimitMinutes'] as int?,
      attemptId: json['attemptId'] as int,
      startedAt: DateTime.tryParse(json['startedAt']?.toString() ?? ''),
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? ''),
      serverTime: DateTime.tryParse(json['serverTime']?.toString() ?? ''),
      courseId: json['courseId'] as int? ?? 0,
      difficulty: json['difficulty'] as String?,
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((e) => QuizQuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}