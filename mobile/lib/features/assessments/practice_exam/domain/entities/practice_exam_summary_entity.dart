class PracticeExamSummaryEntity {
  final int id;
  final String title;
  final String description;
  final int? timeLimitMinutes;
  final int courseId;
  final String? difficulty;
  final int questionCount;
  final bool hasStarted;

  const PracticeExamSummaryEntity({
    required this.id,
    required this.title,
    required this.description,
    this.timeLimitMinutes,
    required this.courseId,
    this.difficulty,
    required this.questionCount,
    required this.hasStarted,
  });
}