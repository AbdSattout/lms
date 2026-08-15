import '../repositories/roadmap_repository.dart';

class UnfollowRoadmapUseCase {
  final RoadmapRepository repository;
  UnfollowRoadmapUseCase(this.repository);
  Future<void> call(String slug, int roadmapId) => repository.unfollowRoadmap(slug, roadmapId);
}