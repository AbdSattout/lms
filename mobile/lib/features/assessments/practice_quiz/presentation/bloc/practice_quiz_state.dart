import '../../domain/entities/practice_quiz_summary_entity.dart';
import '../../domain/entities/practice_quiz_details_entity.dart';
import '../../domain/entities/practice_quiz_submit_result_entity.dart';

sealed class PracticeQuizState {}

class PracticeQuizInitial extends PracticeQuizState {}

class PracticeQuizListLoading extends PracticeQuizState {}

class PracticeQuizListLoaded extends PracticeQuizState {
  final List<PracticeQuizSummaryEntity> quizzes;
  PracticeQuizListLoaded(this.quizzes);
}

class PracticeQuizListEmpty extends PracticeQuizState {}

class PracticeQuizDetailsLoading extends PracticeQuizState {}

class PracticeQuizDetailsReady extends PracticeQuizState {
  final PracticeQuizDetailsEntity quiz;
  final Map<int, int> selectedAnswers;

  PracticeQuizDetailsReady({
    required this.quiz,
    required this.selectedAnswers,
  });

  int get answeredCount => selectedAnswers.length;
  int get totalQuestions => quiz.questions.length;
  bool get allAnswered => answeredCount == totalQuestions;

  PracticeQuizDetailsReady copyWith({Map<int, int>? selectedAnswers}) {
    return PracticeQuizDetailsReady(
      quiz: quiz,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
    );
  }
}

class PracticeQuizSubmitting extends PracticeQuizState {
  final PracticeQuizDetailsReady previousState;
  PracticeQuizSubmitting(this.previousState);
}

class PracticeQuizCompleted extends PracticeQuizState {
  final PracticeQuizSubmitResultEntity result;
  PracticeQuizCompleted(this.result);
}

class PracticeQuizFailed extends PracticeQuizState {
  final String message;
  PracticeQuizFailed(this.message);
}