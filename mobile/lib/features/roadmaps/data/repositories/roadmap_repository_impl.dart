import '../../domain/entities/roadmap_entity.dart';
import '../../domain/repositories/roadmap_repository.dart';
import '../datasources/roadmap_remote_datasource.dart';

class RoadmapRepositoryImpl implements RoadmapRepository {
  final RoadmapRemoteDataSource remoteDataSource;

  RoadmapRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<RoadmapEntity>> getOrganizationRoadmaps(String slug) async {
    return await remoteDataSource.getOrganizationRoadmaps(slug);
  }

  @override
  Future<RoadmapEntity> getRoadmapDetails(String slug, int roadmapId) async {
    return await remoteDataSource.getRoadmapDetails(slug, roadmapId);
  }

  @override
  Future<RoadmapEntity> followRoadmap(String slug, int roadmapId) async {
    return await remoteDataSource.followRoadmap(slug, roadmapId);
  }

  @override
  Future<void> unfollowRoadmap(String slug, int roadmapId) async {
    await remoteDataSource.unfollowRoadmap(slug, roadmapId);
  }
}