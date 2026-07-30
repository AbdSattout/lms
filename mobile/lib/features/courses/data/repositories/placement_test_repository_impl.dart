import '../../domain/entities/placement_test_entity.dart';
import '../../domain/repositories/placement_test_repository.dart';
import '../datasources/placement_test_remote_datasource.dart';

class PlacementTestRepositoryImpl implements PlacementTestRepository {
  final PlacementTestRemoteDataSource remote;

  PlacementTestRepositoryImpl(this.remote);

  @override
  Future<PlacementTestStateEntity> getPlacementTest(int courseId) {
    return remote.getPlacementTest(courseId);
  }

  @override
  Future<PlacementTestStateEntity> submitAnswer({
    required int courseId,
    required int answerIndex,
  }) {
    return remote.submitAnswer(
      courseId: courseId,
      answerIndex: answerIndex,
    );
  }

  @override
  Future<PlacementTestStateEntity> skipPlacementTest(int courseId) {
    return remote.skipPlacementTest(courseId);
  }
}