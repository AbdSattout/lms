import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/api_error_resolver.dart';
import '../../domain/usecases/get_block_content_usecase.dart';
import '../../domain/usecases/submit_block_answer_usecase.dart';
import 'block_content_event.dart';
import 'block_content_state.dart';

class BlockContentBloc extends Bloc<BlockContentEvent, BlockContentState> {
  final GetBlockContentUseCase getBlockContentUseCase;
  final SubmitBlockAnswerUseCase submitBlockAnswerUseCase;

  BlockContentBloc({
    required this.getBlockContentUseCase,
    required this.submitBlockAnswerUseCase,
  }) : super(BlockContentLoading()) {
    on<LoadBlockEvent>(_load);
    on<SubmitBlockAnswerEvent>(_submit);
  }

  Future<void> _load(
      LoadBlockEvent event, Emitter<BlockContentState> emit) async {
    try {
      emit(BlockContentLoading());
      final block = await getBlockContentUseCase(event.blockId);
      emit(BlockContentLoaded(block: block));
    } catch (e) {
      emit(BlockContentError(resolveApiErrorMessage(e)));
    }
  }

  Future<void> _submit(
      SubmitBlockAnswerEvent event, Emitter<BlockContentState> emit) async {
    final current = state;
    if (current is! BlockContentLoaded) return;

    emit(BlockContentLoaded(block: current.block, isSubmitting: true));

    try {
      final result = await submitBlockAnswerUseCase(
        blockId: event.blockId,
        answerIndex: event.answerIndex,
      );

      if (!result.isCorrect) {
        emit(BlockContentLoaded(
          block: current.block,
          isSubmitting: false,
          lastAnswerCorrect: false,
        ));
        return;
      }

      emit(BlockContentLoaded(
        block: current.block,
        isSubmitting: false,
        lastAnswerCorrect: true,
      ));

      if (result.nextType == 'BLOCK' && result.nextBlockId != null) {
        await Future.delayed(const Duration(milliseconds: 700));
        add(LoadBlockEvent(result.nextBlockId!));
      } else {
        await Future.delayed(const Duration(milliseconds: 700));
        emit(BlockContentFinished(
          nextType: result.nextType,
          message: result.message,
        ));
      }
    } catch (e) {
      emit(BlockContentError(resolveApiErrorMessage(e)));
    }
  }
}