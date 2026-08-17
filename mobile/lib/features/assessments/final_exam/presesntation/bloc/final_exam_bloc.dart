import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_final_exam_usecase.dart';
import '../../domain/usecases/submit_final_exam_usecase.dart';
import 'final_exam_event.dart';
import 'final_exam_state.dart';

class FinalExamBloc extends Bloc<FinalExamEvent, FinalExamState> {
  final GetFinalExamUseCase getExam;
  final SubmitFinalExamUseCase submit;

  int? _courseId;

  FinalExamBloc({
    required this.getExam,
    required this.submit,
  }) : super(FinalExamInitial()) {
    on<LoadFinalExam>(_onLoad);
    on<FinalExamAnswerSelected>(_onAnswerSelected);
    on<SubmitFinalExamRequested>(_onSubmit);
  }

  Future<void> _onLoad(
      LoadFinalExam event,
      Emitter<FinalExamState> emit,
      ) async {
    _courseId = event.courseId;
    emit(FinalExamLoading());

    final result = await getExam(event.courseId);

    result.fold(
          (failure) => emit(FinalExamFailed(failure.errMessage)),
          (exam) => emit(FinalExamReady(exam: exam, selectedAnswers: {})),
    );
  }

  Future<void> _onAnswerSelected(
      FinalExamAnswerSelected event,
      Emitter<FinalExamState> emit,
      ) async {
    final current = state;
    if (current is FinalExamReady) {
      final updated = Map<int, int>.from(current.selectedAnswers);
      updated[event.questionId] = event.answerIndex;
      emit(current.copyWith(selectedAnswers: updated));
    }
  }

  Future<void> _onSubmit(
      SubmitFinalExamRequested event,
      Emitter<FinalExamState> emit,
      ) async {
    final current = state;
    if (current is! FinalExamReady) return;
    if (_courseId == null) return;

    emit(FinalExamSubmitting(current));

    final result = await submit(
      courseId: _courseId!,
      answers: current.selectedAnswers,
    );

    result.fold(
          (failure) => emit(FinalExamFailed(failure.errMessage)),
          (result) => emit(FinalExamCompleted(result)),
    );
  }
}