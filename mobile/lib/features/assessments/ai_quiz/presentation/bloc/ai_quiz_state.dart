import '../../domain/entities/ai_quiz_session_entity.dart';
import '../../domain/entities/ai_quiz_submit_result_entity.dart';

sealed class AiQuizState {}

class AiQuizInitial extends AiQuizState {}

class AiQuizGenerating extends AiQuizState {}

class AiQuizSessionReady extends AiQuizState {
  final AiQuizSessionEntity session;
  final Map<int, int> selectedAnswers;

  AiQuizSessionReady({
    required this.session,
    required this.selectedAnswers,
  });

  int get answeredCount => selectedAnswers.length;
  int get totalQuestions => session.questions.length;
  bool get allAnswered => answeredCount == totalQuestions;

  AiQuizSessionReady copyWith({Map<int, int>? selectedAnswers}) {
    return AiQuizSessionReady(
      session: session,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
    );
  }
}

class AiQuizSubmitting extends AiQuizState {
  final AiQuizSessionReady previousState;
  AiQuizSubmitting(this.previousState);
}

class AiQuizCompleted extends AiQuizState {
  final AiQuizSubmitResultEntity result;
  AiQuizCompleted(this.result);
}

class AiQuizFailed extends AiQuizState {
  final String message;
  AiQuizFailed(this.message);
}