abstract class FinalExamEvent {}

class LoadFinalExam extends FinalExamEvent {
  final int courseId;
  LoadFinalExam(this.courseId);
}

class FinalExamAnswerSelected extends FinalExamEvent {
  final int questionId;
  final int answerIndex;
  FinalExamAnswerSelected({required this.questionId, required this.answerIndex});
}

class SubmitFinalExamRequested extends FinalExamEvent {}