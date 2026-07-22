import '../entities/placement_test_entity.dart';
import '../repositories/placement_test_repository.dart';

class SubmitPlacementAnswerUseCase {
  final PlacementTestRepository repository;

  SubmitPlacementAnswerUseCase(this.repository);

  Future<PlacementTestStateEntity> call({
    required int courseId,
    required int answerIndex,
  }) {
    return repository.submitAnswer(
      courseId: courseId,
      answerIndex: answerIndex,
    );
  }
}