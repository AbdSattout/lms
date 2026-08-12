import '../entities/roadmap_entity.dart';
import '../repositories/roadmap_repository.dart';

class FollowRoadmapUseCase {
  final RoadmapRepository repository;
  FollowRoadmapUseCase(this.repository);
  Future<RoadmapEntity> call(String slug, int roadmapId) => repository.followRoadmap(slug, roadmapId);
}