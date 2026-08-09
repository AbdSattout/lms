import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/api_error_resolver.dart';
import '../../domain/entities/placement_test_entity.dart';
import '../../domain/usecases/get_placement_test_usecase.dart';
import '../../domain/usecases/skip_placement_test_usecase.dart';
import '../../domain/usecases/submit_placement_answer_usecase.dart';
import 'placement_test_event.dart';
import 'placement_test_state.dart';

class PlacementTestBloc extends Bloc<PlacementTestEvent, PlacementTestState> {
  static const int _maxHearts = 2;
  static const Duration _heartLossDelay = Duration(milliseconds: 650);
  static const Duration _correctAnswerDelay = Duration(milliseconds: 550);

  final GetPlacementTestUseCase getPlacementTestUseCase;
  final SubmitPlacementAnswerUseCase submitPlacementAnswerUseCase;
  final SkipPlacementTestUseCase skipPlacementTestUseCase;

  int? _courseId;
  int _heartsRemaining = _maxHearts;

  PlacementTestBloc({
    required this.getPlacementTestUseCase,
    required this.submitPlacementAnswerUseCase,
    required this.skipPlacementTestUseCase,
  }) : super(PlacementTestInitial()) {
    on<StartPlacementTestEvent>(_start);
    on<SubmitPlacementAnswerEvent>(_submitAnswer);
    on<SkipPlacementTestEvent>(_skip);
  }

  Future<void> _start(
    StartPlacementTestEvent event,
    Emitter<PlacementTestState> emit,
  ) async {
    try {
      emit(PlacementTestLoading());
      _courseId = event.courseId;

      final data = await getPlacementTestUseCase(event.courseId);
      _heartsRemaining = _resolveHearts(data, fallback: _maxHearts);

      if (data.completed) {
        emit(PlacementTestCompleted(data));
      } else {
        emit(
          PlacementTestInProgress(
            data: data,
            heartsRemaining: _heartsRemaining,
          ),
        );
      }
    } catch (e) {
      emit(PlacementTestError(resolveApiErrorMessage(e)));
    }
  }

  Future<void> _submitAnswer(
    SubmitPlacementAnswerEvent event,
    Emitter<PlacementTestState> emit,
  ) async {
    if (_courseId == null) return;

    final current = state;
    if (current is! PlacementTestInProgress || current.isSubmitting) return;

    try {
      final previousHearts = _heartsRemaining;

      emit(
        PlacementTestInProgress(
          data: current.data,
          heartsRemaining: previousHearts,
          submittedAnswerIndex: event.answerIndex,
          isSubmitting: true,
        ),
      );

      final result = await submitPlacementAnswerUseCase(
        courseId: _courseId!,
        answerIndex: event.answerIndex,
      );

      _heartsRemaining = _resolveHearts(
        result,
        fallback: _fallbackHearts(
          correct: result.correct,
          completed: result.completed,
          previousHearts: previousHearts,
        ),
      );

      if (result.correct == false) {
        emit(
          PlacementTestInProgress(
            data: result,
            heartsRemaining: _heartsRemaining,
            lastAnswerCorrect: result.correct,
            submittedAnswerIndex: event.answerIndex,
          ),
        );

        if (result.completed) {
          await Future<void>.delayed(_heartLossDelay);
          if (emit.isDone) return;
          emit(PlacementTestCompleted(result));
          return;
        }

        if (_heartsRemaining <= 0) {
          await Future<void>.delayed(_heartLossDelay);
          if (emit.isDone) return;
          final skipResult = await skipPlacementTestUseCase(_courseId!);
          emit(PlacementTestCompleted(skipResult));
          return;
        }

        return;
      }

      if (result.completed) {
        emit(
          PlacementTestInProgress(
            data: current.data,
            heartsRemaining: _heartsRemaining,
            lastAnswerCorrect: true,
            submittedAnswerIndex: event.answerIndex,
          ),
        );
        await Future<void>.delayed(_correctAnswerDelay);
        if (emit.isDone) return;
        emit(PlacementTestCompleted(result));
        return;
      }

      if (_heartsRemaining <= 0) {
        final skipResult = await skipPlacementTestUseCase(_courseId!);
        emit(PlacementTestCompleted(skipResult));
        return;
      }

      emit(
        PlacementTestInProgress(
          data: current.data,
          heartsRemaining: _heartsRemaining,
          lastAnswerCorrect: true,
          submittedAnswerIndex: event.answerIndex,
        ),
      );

      await Future<void>.delayed(_correctAnswerDelay);
      if (emit.isDone) return;

      emit(
        PlacementTestInProgress(
          data: result,
          heartsRemaining: _heartsRemaining,
        ),
      );
    } catch (e) {
      emit(PlacementTestError(resolveApiErrorMessage(e)));
    }
  }

  Future<void> _skip(
    SkipPlacementTestEvent event,
    Emitter<PlacementTestState> emit,
  ) async {
    if (_courseId == null) return;

    try {
      final result = await skipPlacementTestUseCase(_courseId!);
      emit(PlacementTestCompleted(result));
    } catch (e) {
      emit(PlacementTestError(resolveApiErrorMessage(e)));
    }
  }

  int _resolveHearts(PlacementTestStateEntity data, {required int fallback}) {
    final hearts = data.remainingHearts ?? fallback;
    return hearts.clamp(0, _maxHearts).toInt();
  }

  int _fallbackHearts({
    required bool? correct,
    required bool completed,
    required int previousHearts,
  }) {
    if (correct == false) {
      if (completed) return 0;
      return previousHearts - 1;
    }

    return previousHearts;
  }
}
