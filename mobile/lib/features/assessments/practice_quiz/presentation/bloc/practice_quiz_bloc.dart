import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_practice_quiz_list_usecase.dart';
import '../../domain/usecases/get_practice_quiz_details_usecase.dart';
import '../../domain/usecases/submit_practice_quiz_usecase.dart';
import 'practice_quiz_event.dart';
import 'practice_quiz_state.dart';

class PracticeQuizBloc extends Bloc<PracticeQuizEvent, PracticeQuizState> {
  final GetPracticeQuizListUseCase getList;
  final GetPracticeQuizDetailsUseCase getDetails;
  final SubmitPracticeQuizUseCase submit;

  int? _courseId;
  int? _quizId;

  PracticeQuizBloc({
    required this.getList,
    required this.getDetails,
    required this.submit,
  }) : super(PracticeQuizInitial()) {
    on<LoadPracticeQuizList>(_onLoadList);
    on<LoadPracticeQuizDetails>(_onLoadDetails);
    on<PracticeQuizAnswerSelected>(_onAnswerSelected);
    on<SubmitPracticeQuizRequested>(_onSubmit);
  }

  Future<void> _onLoadList(
      LoadPracticeQuizList event,
      Emitter<PracticeQuizState> emit,
      ) async {
    _courseId = event.courseId;
    emit(PracticeQuizListLoading());

    final result = await getList(event.courseId);

    result.fold(
          (failure) => emit(PracticeQuizFailed(failure.errMessage)),
          (quizzes) {
        if (quizzes.isEmpty) {
          emit(PracticeQuizListEmpty());
        } else {
          emit(PracticeQuizListLoaded(quizzes));
        }
      },
    );
  }

  Future<void> _onLoadDetails(
      LoadPracticeQuizDetails event,
      Emitter<PracticeQuizState> emit,
      ) async {
    _courseId = event.courseId;
    _quizId = event.quizId;
    emit(PracticeQuizDetailsLoading());

    final result = await getDetails(courseId: event.courseId, quizId: event.quizId);

    result.fold(
          (failure) => emit(PracticeQuizFailed(failure.errMessage)),
          (quiz) => emit(PracticeQuizDetailsReady(quiz: quiz, selectedAnswers: {})),
    );
  }

  Future<void> _onAnswerSelected(
      PracticeQuizAnswerSelected event,
      Emitter<PracticeQuizState> emit,
      ) async {
    final current = state;
    if (current is PracticeQuizDetailsReady) {
      final updated = Map<int, int>.from(current.selectedAnswers);
      updated[event.questionId] = event.answerIndex;
      emit(current.copyWith(selectedAnswers: updated));
    }
  }

  Future<void> _onSubmit(
      SubmitPracticeQuizRequested event,
      Emitter<PracticeQuizState> emit,
      ) async {
    final current = state;
    if (current is! PracticeQuizDetailsReady) return;
    if (_courseId == null || _quizId == null) return;

    emit(PracticeQuizSubmitting(current));

    final result = await submit(
      courseId: _courseId!,
      quizId: _quizId!,
      answers: current.selectedAnswers,
    );

    result.fold(
          (failure) => emit(PracticeQuizFailed(failure.errMessage)),
          (result) => emit(PracticeQuizCompleted(result)),
    );
  }
}