import '../entities/roadmap_entity.dart';
import '../repositories/roadmap_repository.dart';

class GetOrganizationRoadmapsUseCase {
  final RoadmapRepository repository;
  GetOrganizationRoadmapsUseCase(this.repository);
  Future<List<RoadmapEntity>> call(String slug) => repository.getOrganizationRoadmaps(slug);
}