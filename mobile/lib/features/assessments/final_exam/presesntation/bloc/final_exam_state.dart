import '../../domain/entities/final_exam_details_entity.dart';
import '../../domain/entities/final_exam_submit_result_entity.dart';

sealed class FinalExamState {}

class FinalExamInitial extends FinalExamState {}

class FinalExamLoading extends FinalExamState {}

class FinalExamReady extends FinalExamState {
  final FinalExamDetailsEntity exam;
  final Map<int, int> selectedAnswers;

  FinalExamReady({required this.exam, required this.selectedAnswers});

  int get answeredCount => selectedAnswers.length;
  int get totalQuestions => exam.questions.length;
  bool get allAnswered => answeredCount == totalQuestions;

  FinalExamReady copyWith({Map<int, int>? selectedAnswers}) {
    return FinalExamReady(
      exam: exam,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
    );
  }
}

class FinalExamSubmitting extends FinalExamState {
  final FinalExamReady previousState;
  FinalExamSubmitting(this.previousState);
}

class FinalExamCompleted extends FinalExamState {
  final FinalExamSubmitResultEntity result;
  FinalExamCompleted(this.result);
}

class FinalExamFailed extends FinalExamState {
  final String message;
  FinalExamFailed(this.message);
}