import '../../../../core/databases/api/api_consumer.dart';
import '../../../../core/databases/api/end_points.dart';
import '../models/placement_test_model.dart';

abstract class PlacementTestRemoteDataSource {
  Future<PlacementTestStateModel> getPlacementTest(int courseId);

  Future<PlacementTestStateModel> submitAnswer({
    required int courseId,
    required int answerIndex,
  });

  Future<PlacementTestStateModel> skipPlacementTest(int courseId);
}

class PlacementTestRemoteDataSourceImpl
    implements PlacementTestRemoteDataSource {
  final ApiConsumer api;

  PlacementTestRemoteDataSourceImpl(this.api);

  @override
  Future<PlacementTestStateModel> getPlacementTest(int courseId) async {
    final response = await api.get(
      EndPoints.placementTest(courseId),
    );

    return PlacementTestStateModel.fromJson(response);
  }

  @override
  Future<PlacementTestStateModel> submitAnswer({
    required int courseId,
    required int answerIndex,
  }) async {
    final response = await api.post(
      EndPoints.placementTest(courseId),
      data: {
        'answerIndex': answerIndex,
      },
    );

    return PlacementTestStateModel.fromJson(response);
  }

  @override
  Future<PlacementTestStateModel> skipPlacementTest(int courseId) async {
    final response = await api.post(
      EndPoints.skipPlacementTest(courseId),
    );

    return PlacementTestStateModel.fromJson(response);
  }
}