import '../entities/placement_test_entity.dart';
import '../repositories/placement_test_repository.dart';

class GetPlacementTestUseCase {
  final PlacementTestRepository repository;

  GetPlacementTestUseCase(this.repository);

  Future<PlacementTestStateEntity> call(int courseId) {
    return repository.getPlacementTest(courseId);
  }
}