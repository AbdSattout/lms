import '../entities/roadmap_entity.dart';
import '../repositories/roadmap_repository.dart';

class GetRoadmapDetailsUseCase {
  final RoadmapRepository repository;
  GetRoadmapDetailsUseCase(this.repository);
  Future<RoadmapEntity> call(String slug, int roadmapId) => repository.getRoadmapDetails(slug, roadmapId);
}