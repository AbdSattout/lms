import '../../domain/entities/practice_exam_summary_entity.dart';
import '../../domain/entities/practice_exam_details_entity.dart';
import '../../domain/entities/practice_exam_submit_result_entity.dart';

sealed class PracticeExamState {}

class PracticeExamInitial extends PracticeExamState {}

class PracticeExamListLoading extends PracticeExamState {}

class PracticeExamListLoaded extends PracticeExamState {
  final List<PracticeExamSummaryEntity> exams;
  PracticeExamListLoaded(this.exams);
}

class PracticeExamListEmpty extends PracticeExamState {}

class PracticeExamDetailsLoading extends PracticeExamState {}

class PracticeExamDetailsReady extends PracticeExamState {
  final PracticeExamDetailsEntity exam;
  final Map<int, int> selectedAnswers;

  PracticeExamDetailsReady({required this.exam, required this.selectedAnswers});

  int get answeredCount => selectedAnswers.length;
  int get totalQuestions => exam.questions.length;
  bool get allAnswered => answeredCount == totalQuestions;

  PracticeExamDetailsReady copyWith({Map<int, int>? selectedAnswers}) {
    return PracticeExamDetailsReady(
      exam: exam,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
    );
  }
}

class PracticeExamSubmitting extends PracticeExamState {
  final PracticeExamDetailsReady previousState;
  PracticeExamSubmitting(this.previousState);
}

class PracticeExamCompleted extends PracticeExamState {
  final PracticeExamSubmitResultEntity result;
  PracticeExamCompleted(this.result);
}

class PracticeExamFailed extends PracticeExamState {
  final String message;
  PracticeExamFailed(this.message);
}