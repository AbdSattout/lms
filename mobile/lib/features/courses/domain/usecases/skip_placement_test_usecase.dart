import '../entities/placement_test_entity.dart';
import '../repositories/placement_test_repository.dart';

class SkipPlacementTestUseCase {
  final PlacementTestRepository repository;

  SkipPlacementTestUseCase(this.repository);

  Future<PlacementTestStateEntity> call(int courseId) {
    return repository.skipPlacementTest(courseId);
  }
}