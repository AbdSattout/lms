import '../../../../core/databases/api/api_consumer.dart';
import '../../../../core/databases/api/end_points.dart';
import '../models/roadmap_model.dart';

abstract class RoadmapRemoteDataSource {
  Future<List<RoadmapModel>> getOrganizationRoadmaps(String slug);
  Future<RoadmapModel> getRoadmapDetails(String slug, int roadmapId);
  Future<RoadmapModel> followRoadmap(String slug, int roadmapId);
  Future<void> unfollowRoadmap(String slug, int roadmapId);
  Future<List<RoadmapModel>> getMyRoadmaps();
}

class RoadmapRemoteDataSourceImpl implements RoadmapRemoteDataSource {
  final ApiConsumer api;

  RoadmapRemoteDataSourceImpl({required this.api});

  @override
  Future<List<RoadmapModel>> getOrganizationRoadmaps(String slug) async {
    final response = await api.get(EndPoints.organizationRoadmaps(slug));
    final content = (response['content'] as List<dynamic>?) ?? [];
    return content
        .map((e) => RoadmapModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<RoadmapModel> getRoadmapDetails(String slug, int roadmapId) async {
    final response = await api.get(EndPoints.roadmapDetails(slug, roadmapId));
    print('📦 FOLLOW STATUS: ${response['followStatus']}');
    print('📦 FULL KEYS: ${response.keys}');
    return RoadmapModel.fromJson(response);
  }

  @override
  Future<RoadmapModel> followRoadmap(String slug, int roadmapId) async {
    final response = await api.post(EndPoints.followRoadmap(slug, roadmapId));
    print('📦 FOLLOW RESPONSE: $response');
    return RoadmapModel.fromJson(response);
  }

  @override
  Future<void> unfollowRoadmap(String slug, int roadmapId) async {
    await api.delete(EndPoints.followRoadmap(slug, roadmapId));
  }
  @override
  Future<List<RoadmapModel>> getMyRoadmaps() async {
    final response = await api.get(EndPoints.myRoadmaps);
    final content = (response['content'] as List<dynamic>?) ?? [];
    return content
        .map((e) => RoadmapModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}