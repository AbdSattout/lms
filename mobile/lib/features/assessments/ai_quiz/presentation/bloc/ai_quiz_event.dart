abstract class AiQuizEvent {}

class GenerateAiQuizRequested extends AiQuizEvent {
  final int courseId;
  GenerateAiQuizRequested(this.courseId);
}

class AiQuizAnswerSelected extends AiQuizEvent {
  final int questionId;
  final int answerIndex;
  AiQuizAnswerSelected({required this.questionId, required this.answerIndex});
}

class SubmitAiQuizRequested extends AiQuizEvent {}