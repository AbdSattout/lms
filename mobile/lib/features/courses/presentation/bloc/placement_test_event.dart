abstract class PlacementTestEvent {}

class StartPlacementTestEvent extends PlacementTestEvent {
  final int courseId;
  StartPlacementTestEvent(this.courseId);
}

class SubmitPlacementAnswerEvent extends PlacementTestEvent {
  final int answerIndex;
  SubmitPlacementAnswerEvent(this.answerIndex);
}

class SkipPlacementTestEvent extends PlacementTestEvent {}