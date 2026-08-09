import '../../domain/entities/block_content_entity.dart';

abstract class BlockContentState {}

class BlockContentLoading extends BlockContentState {}

class BlockContentLoaded extends BlockContentState {
  final BlockContentEntity block;
  final bool isSubmitting;
  final bool? lastAnswerCorrect;
  final int? submittedAnswerIndex;
  final BlockAnswerResultEntity? answerResult;

  BlockContentLoaded({
    required this.block,
    this.isSubmitting = false,
    this.lastAnswerCorrect,
    this.submittedAnswerIndex,
    this.answerResult,
  });
}

class BlockContentFinished extends BlockContentState {
  final String nextType;
  final String message;
  BlockContentFinished({required this.nextType, required this.message});
}

class BlockContentError extends BlockContentState {
  final String message;
  BlockContentError(this.message);
}
