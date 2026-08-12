import '../entities/roadmap_entity.dart';
import '../repositories/roadmap_repository.dart';

class GetMyRoadmapsUseCase {
  final RoadmapRepository repository;
  GetMyRoadmapsUseCase(this.repository);
  Future<List<RoadmapEntity>> call() => repository.getMyRoadmaps();
}