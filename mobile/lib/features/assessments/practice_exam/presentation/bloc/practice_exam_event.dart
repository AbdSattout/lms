abstract class PracticeExamEvent {}

class LoadPracticeExamList extends PracticeExamEvent {
  final int courseId;
  LoadPracticeExamList(this.courseId);
}

class LoadPracticeExamDetails extends PracticeExamEvent {
  final int courseId;
  final int examId;
  LoadPracticeExamDetails({required this.courseId, required this.examId});
}

class PracticeExamAnswerSelected extends PracticeExamEvent {
  final int questionId;
  final int answerIndex;
  PracticeExamAnswerSelected({required this.questionId, required this.answerIndex});
}

class SubmitPracticeExamRequested extends PracticeExamEvent {}