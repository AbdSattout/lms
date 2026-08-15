abstract class PracticeQuizEvent {}

class LoadPracticeQuizList extends PracticeQuizEvent {
  final int courseId;
  LoadPracticeQuizList(this.courseId);
}

class LoadPracticeQuizDetails extends PracticeQuizEvent {
  final int courseId;
  final int quizId;
  LoadPracticeQuizDetails({required this.courseId, required this.quizId});
}

class PracticeQuizAnswerSelected extends PracticeQuizEvent {
  final int questionId;
  final int answerIndex;
  PracticeQuizAnswerSelected({required this.questionId, required this.answerIndex});
}

class SubmitPracticeQuizRequested extends PracticeQuizEvent {}