class AiQuizQuestionResultEntity {
  final int questionId;
  final String content;
  final List<String> options;
  final int? selectedAnswerIndex;
  final int correctAnswerIndex;
  final bool correct;

  const AiQuizQuestionResultEntity({
    required this.questionId,
    required this.content,
    required this.options,
    this.selectedAnswerIndex,
    required this.correctAnswerIndex,
    required this.correct,
  });
}