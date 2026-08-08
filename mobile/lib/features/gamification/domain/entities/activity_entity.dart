class ActivityEntity {
  final String date;
  final int xpEarned;
  final int completedBlocks;
  final int completedLessons;
  final int completedChapters;
  final int completedCourses;
  final int completedPracticeQuizzes;
  final int completedFinalQuizzes;
  final int completedQuizzes;
  final int correctQuestions;
  final int enrollments;
  final int totalActions;

  const ActivityEntity({
    required this.date,
    required this.xpEarned,
    required this.completedBlocks,
    required this.completedLessons,
    required this.completedChapters,
    required this.completedCourses,
    required this.completedPracticeQuizzes,
    required this.completedFinalQuizzes,
    required this.completedQuizzes,
    required this.correctQuestions,
    required this.enrollments,
    required this.totalActions,
  });
}