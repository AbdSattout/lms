class PlacementQuestionEntity {
  final int blockId;
  final int lessonId;
  final int chapterId;
  final int questionId;
  final String content;
  final List<String> options;

  const PlacementQuestionEntity({
    required this.blockId,
    required this.lessonId,
    required this.chapterId,
    required this.questionId,
    required this.content,
    required this.options,
  });
}

class PlacementTestStateEntity {
  final bool? correct;
  final bool completed;
  final int correctAnswers;
  final int totalAnswers;

  final int? remainingHearts;

  final PlacementQuestionEntity? question;
  final int? startBlockId;
  final int? startLessonId;
  final int? startChapterId;
  final double progressPercentage;
  final String message;

  const PlacementTestStateEntity({
    this.correct,
    required this.completed,
    required this.correctAnswers,
    required this.totalAnswers,
    this.remainingHearts,
    this.question,
    this.startBlockId,
    this.startLessonId,
    this.startChapterId,
    required this.progressPercentage,
    required this.message,
  });
}