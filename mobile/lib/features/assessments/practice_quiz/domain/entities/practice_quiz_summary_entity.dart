class PracticeQuizSummaryEntity {
  final int id;
  final String title;
  final String description;
  final int courseId;
  final String? difficulty;
  final int questionCount;

  const PracticeQuizSummaryEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    this.difficulty,
    required this.questionCount,
  });
}