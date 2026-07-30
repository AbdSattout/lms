import '../../domain/entities/placement_test_entity.dart';

abstract class PlacementTestState {}

class PlacementTestInitial extends PlacementTestState {}

class PlacementTestLoading extends PlacementTestState {}

class PlacementTestInProgress extends PlacementTestState {
  final PlacementTestStateEntity data;
  final int heartsRemaining;
  final bool? lastAnswerCorrect;

  PlacementTestInProgress({
    required this.data,
    required this.heartsRemaining,
    this.lastAnswerCorrect,
  });
}

class PlacementTestCompleted extends PlacementTestState {
  final PlacementTestStateEntity data;

  PlacementTestCompleted(this.data);
}

class PlacementTestError extends PlacementTestState {
  final String message;

  PlacementTestError(this.message);
}