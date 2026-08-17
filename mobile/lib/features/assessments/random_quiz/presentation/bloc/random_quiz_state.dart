import '../../domain/entities/random_quiz_session_entity.dart';
import '../../domain/entities/random_quiz_submit_result_entity.dart';

sealed class RandomQuizState {}

class RandomQuizInitial extends RandomQuizState {}

class RandomQuizGenerating extends RandomQuizState {}

class RandomQuizSessionReady extends RandomQuizState {
  final RandomQuizSessionEntity session;
  final Map<int, int> selectedAnswers;

  RandomQuizSessionReady({
    required this.session,
    required this.selectedAnswers,
  });

  int get answeredCount => selectedAnswers.length;
  int get totalQuestions => session.questions.length;
  bool get allAnswered => answeredCount == totalQuestions;

  RandomQuizSessionReady copyWith({Map<int, int>? selectedAnswers}) {
    return RandomQuizSessionReady(
      session: session,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
    );
  }
}

class RandomQuizSubmitting extends RandomQuizState {
  final RandomQuizSessionReady previousState;
  RandomQuizSubmitting(this.previousState);
}

class RandomQuizCompleted extends RandomQuizState {
  final RandomQuizSubmitResultEntity result;
  RandomQuizCompleted(this.result);
}

class RandomQuizFailed extends RandomQuizState {
  final String message;
  RandomQuizFailed(this.message);
}