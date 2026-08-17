import '../../domain/entities/practice_exam_summary_entity.dart';

class PracticeExamSummaryModel extends PracticeExamSummaryEntity {
  const PracticeExamSummaryModel({
    required super.id,
    required super.title,
    required super.description,
    super.timeLimitMinutes,
    required super.courseId,
    super.difficulty,
    required super.questionCount,
  });

  factory PracticeExamSummaryModel.fromJson(Map<String, dynamic> json) {
    return PracticeExamSummaryModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      timeLimitMinutes: json['timeLimitMinutes'] as int?,
      courseId: json['courseId'] as int? ?? 0,
      difficulty: json['difficulty'] as String?,
      questionCount: json['questionCount'] as int? ?? 0,
    );
  }
}