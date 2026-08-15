import '../entities/roadmap_entity.dart';

abstract class RoadmapRepository {
  Future<List<RoadmapEntity>> getOrganizationRoadmaps(String slug);
  Future<RoadmapEntity> getRoadmapDetails(String slug, int roadmapId);
  Future<RoadmapEntity> followRoadmap(String slug, int roadmapId);
  Future<void> unfollowRoadmap(String slug, int roadmapId);
  Future<List<RoadmapEntity>> getMyRoadmaps();
}