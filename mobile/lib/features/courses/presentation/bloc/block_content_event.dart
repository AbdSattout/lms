abstract class BlockContentEvent {}

class LoadBlockEvent extends BlockContentEvent {
  final int blockId;
  LoadBlockEvent(this.blockId);
}

class SubmitBlockAnswerEvent extends BlockContentEvent {
  final int blockId;
  final int answerIndex;
  SubmitBlockAnswerEvent({required this.blockId, required this.answerIndex});
}