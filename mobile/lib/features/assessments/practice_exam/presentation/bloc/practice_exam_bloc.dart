import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_practice_exam_list_usecase.dart';
import '../../domain/usecases/get_practice_exam_details_usecase.dart';
import '../../domain/usecases/submit_practice_exam_usecase.dart';
import 'practice_exam_event.dart';
import 'practice_exam_state.dart';

class PracticeExamBloc extends Bloc<PracticeExamEvent, PracticeExamState> {
  final GetPracticeExamListUseCase getList;
  final GetPracticeExamDetailsUseCase getDetails;
  final SubmitPracticeExamUseCase submit;

  int? _courseId;
  int? _examId;

  PracticeExamBloc({
    required this.getList,
    required this.getDetails,
    required this.submit,
  }) : super(PracticeExamInitial()) {
    on<LoadPracticeExamList>(_onLoadList);
    on<LoadPracticeExamDetails>(_onLoadDetails);
    on<PracticeExamAnswerSelected>(_onAnswerSelected);
    on<SubmitPracticeExamRequested>(_onSubmit);
  }

  Future<void> _onLoadList(
      LoadPracticeExamList event,
      Emitter<PracticeExamState> emit,
      ) async {
    _courseId = event.courseId;
    emit(PracticeExamListLoading());

    final result = await getList(event.courseId);

    result.fold(
          (failure) => emit(PracticeExamFailed(failure.errMessage)),
          (exams) {
        if (exams.isEmpty) {
          emit(PracticeExamListEmpty());
        } else {
          emit(PracticeExamListLoaded(exams));
        }
      },
    );
  }

  Future<void> _onLoadDetails(
      LoadPracticeExamDetails event,
      Emitter<PracticeExamState> emit,
      ) async {
    _courseId = event.courseId;
    _examId = event.examId;
    emit(PracticeExamDetailsLoading());

    final result = await getDetails(courseId: event.courseId, examId: event.examId);

    result.fold(
          (failure) => emit(PracticeExamFailed(failure.errMessage)),
          (exam) => emit(PracticeExamDetailsReady(exam: exam, selectedAnswers: {})),
    );
  }

  Future<void> _onAnswerSelected(
      PracticeExamAnswerSelected event,
      Emitter<PracticeExamState> emit,
      ) async {
    final current = state;
    if (current is PracticeExamDetailsReady) {
      final updated = Map<int, int>.from(current.selectedAnswers);
      updated[event.questionId] = event.answerIndex;
      emit(current.copyWith(selectedAnswers: updated));
    }
  }

  Future<void> _onSubmit(
      SubmitPracticeExamRequested event,
      Emitter<PracticeExamState> emit,
      ) async {
    final current = state;
    if (current is! PracticeExamDetailsReady) return;
    if (_courseId == null || _examId == null) return;

    emit(PracticeExamSubmitting(current));

    final result = await submit(
      courseId: _courseId!,
      examId: _examId!,
      attemptId: current.exam.attemptId,
      answers: current.selectedAnswers,
    );

    result.fold(
          (failure) => emit(PracticeExamFailed(failure.errMessage)),
          (result) => emit(PracticeExamCompleted(result)),
    );
  }
}