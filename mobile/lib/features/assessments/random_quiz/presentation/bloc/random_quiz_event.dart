abstract class RandomQuizEvent {}

class GenerateRandomQuizRequested extends RandomQuizEvent {
  final int courseId;
  final String difficulty;
  final int count;
  GenerateRandomQuizRequested({
    required this.courseId,
    required this.difficulty,
    required this.count,
  });
}

class RandomQuizAnswerSelected extends RandomQuizEvent {
  final int questionId;
  final int answerIndex;
  RandomQuizAnswerSelected({required this.questionId, required this.answerIndex});
}

class SubmitRandomQuizRequested extends RandomQuizEvent {}