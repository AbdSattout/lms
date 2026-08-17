import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/generate_ai_quiz_usecase.dart';
import '../../domain/usecases/submit_ai_quiz_usecase.dart';
import 'ai_quiz_event.dart';
import 'ai_quiz_state.dart';

class AiQuizBloc extends Bloc<AiQuizEvent, AiQuizState> {
  final GenerateAiQuizUseCase generateAiQuiz;
  final SubmitAiQuizUseCase submitAiQuiz;

  int? _courseId;

  AiQuizBloc({
    required this.generateAiQuiz,
    required this.submitAiQuiz,
  }) : super(AiQuizInitial()) {
    on<GenerateAiQuizRequested>(_onGenerate);
    on<AiQuizAnswerSelected>(_onAnswerSelected);
    on<SubmitAiQuizRequested>(_onSubmit);
  }

  Future<void> _onGenerate(
      GenerateAiQuizRequested event,
      Emitter<AiQuizState> emit,
      ) async {
    _courseId = event.courseId;
    emit(AiQuizGenerating());

    final result = await generateAiQuiz(event.courseId);

    result.fold(
          (failure) => emit(AiQuizFailed(failure.errMessage)),
          (session) => emit(AiQuizSessionReady(
        session: session,
        selectedAnswers: {},
      )),
    );
  }

  Future<void> _onAnswerSelected(
      AiQuizAnswerSelected event,
      Emitter<AiQuizState> emit,
      ) async {
    final current = state;
    if (current is AiQuizSessionReady) {
      final updatedAnswers = Map<int, int>.from(current.selectedAnswers);
      updatedAnswers[event.questionId] = event.answerIndex;
      emit(current.copyWith(selectedAnswers: updatedAnswers));
    }
  }

  Future<void> _onSubmit(
      SubmitAiQuizRequested event,
      Emitter<AiQuizState> emit,
      ) async {
    final current = state;
    if (current is! AiQuizSessionReady) return;
    if (_courseId == null) return;

    emit(AiQuizSubmitting(current));

    final result = await submitAiQuiz(
      courseId: _courseId!,
      attemptId: current.session.attemptId,
      answers: current.selectedAnswers,
    );

    result.fold(
          (failure) => emit(AiQuizFailed(failure.errMessage)),
          (result) => emit(AiQuizCompleted(result)),
    );
  }
}