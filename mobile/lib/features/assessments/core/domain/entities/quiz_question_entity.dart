class QuizQuestionEntity {
  final int id;
  final String content;
  final List<String> options;
  final String? difficulty;

  const QuizQuestionEntity({
    required this.id,
    required this.content,
    required this.options,
    this.difficulty,
  });
}