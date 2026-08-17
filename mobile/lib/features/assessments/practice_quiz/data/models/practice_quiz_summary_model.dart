import '../../domain/entities/practice_quiz_summary_entity.dart';

class PracticeQuizSummaryModel extends PracticeQuizSummaryEntity {
  const PracticeQuizSummaryModel({
    required super.id,
    required super.title,
    required super.description,
    required super.courseId,
    super.difficulty,
    required super.questionCount,
  });

  factory PracticeQuizSummaryModel.fromJson(Map<String, dynamic> json) {
    return PracticeQuizSummaryModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      courseId: json['courseId'] as int? ?? 0,
      difficulty: json['difficulty'] as String?,
      questionCount: json['questionCount'] as int? ?? 0,
    );
  }
}