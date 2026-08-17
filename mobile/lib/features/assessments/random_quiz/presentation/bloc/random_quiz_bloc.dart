import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/generate_random_quiz_usecase.dart';
import '../../domain/usecases/submit_random_quiz_usecase.dart';
import 'random_quiz_event.dart';
import 'random_quiz_state.dart';

class RandomQuizBloc extends Bloc<RandomQuizEvent, RandomQuizState> {
  final GenerateRandomQuizUseCase generateRandomQuiz;
  final SubmitRandomQuizUseCase submitRandomQuiz;

  int? _courseId;

  RandomQuizBloc({
    required this.generateRandomQuiz,
    required this.submitRandomQuiz,
  }) : super(RandomQuizInitial()) {
    on<GenerateRandomQuizRequested>(_onGenerate);
    on<RandomQuizAnswerSelected>(_onAnswerSelected);
    on<SubmitRandomQuizRequested>(_onSubmit);
  }

  Future<void> _onGenerate(
      GenerateRandomQuizRequested event,
      Emitter<RandomQuizState> emit,
      ) async {
    _courseId = event.courseId;
    emit(RandomQuizGenerating());

    final result = await generateRandomQuiz(
      courseId: event.courseId,
      difficulty: event.difficulty,
      count: event.count,
    );

    result.fold(
          (failure) => emit(RandomQuizFailed(failure.errMessage)),
          (session) => emit(RandomQuizSessionReady(
        session: session,
        selectedAnswers: {},
      )),
    );
  }

  Future<void> _onAnswerSelected(
      RandomQuizAnswerSelected event,
      Emitter<RandomQuizState> emit,
      ) async {
    final current = state;
    if (current is RandomQuizSessionReady) {
      final updated = Map<int, int>.from(current.selectedAnswers);
      updated[event.questionId] = event.answerIndex;
      emit(current.copyWith(selectedAnswers: updated));
    }
  }

  Future<void> _onSubmit(
      SubmitRandomQuizRequested event,
      Emitter<RandomQuizState> emit,
      ) async {
    final current = state;
    if (current is! RandomQuizSessionReady) return;
    if (_courseId == null) return;

    emit(RandomQuizSubmitting(current));

    final result = await submitRandomQuiz(
      courseId: _courseId!,
      attemptId: current.session.attemptId,
      answers: current.selectedAnswers,
    );

    result.fold(
          (failure) => emit(RandomQuizFailed(failure.errMessage)),
          (result) => emit(RandomQuizCompleted(result)),
    );
  }
}