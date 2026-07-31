import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/api_error_resolver.dart';
import '../../domain/usecases/get_placement_test_usecase.dart';
import '../../domain/usecases/skip_placement_test_usecase.dart';
import '../../domain/usecases/submit_placement_answer_usecase.dart';
import 'placement_test_event.dart';
import 'placement_test_state.dart';

class PlacementTestBloc
    extends Bloc<PlacementTestEvent, PlacementTestState> {

  final GetPlacementTestUseCase getPlacementTestUseCase;
  final SubmitPlacementAnswerUseCase submitPlacementAnswerUseCase;
  final SkipPlacementTestUseCase skipPlacementTestUseCase;

  int? _courseId;

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

      if (data.completed) {
        emit(PlacementTestCompleted(data));
      } else {
        emit(PlacementTestInProgress(
          data: data,
          heartsRemaining: data.remainingHearts ?? 2,
        ));
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

    try {
      final result = await submitPlacementAnswerUseCase(
        courseId: _courseId!,
        answerIndex: event.answerIndex,
      );

      if (result.completed) {
        emit(PlacementTestCompleted(result));
        return;
      }

      final hearts = result.remainingHearts ?? 0;

      if (hearts <= 0) {
        final skipResult = await skipPlacementTestUseCase(_courseId!);
        emit(PlacementTestCompleted(skipResult));
        return;
      }

      emit(PlacementTestInProgress(
        data: result,
        heartsRemaining: hearts,
        lastAnswerCorrect: result.correct,
      ));
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
}