import '../entities/placement_test_entity.dart';

abstract class PlacementTestRepository {
  Future<PlacementTestStateEntity> getPlacementTest(int courseId);

  Future<PlacementTestStateEntity> submitAnswer({
    required int courseId,
    required int answerIndex,
  });

  Future<PlacementTestStateEntity> skipPlacementTest(int courseId);
}