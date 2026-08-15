import '../../domain/entities/recommended_course_entity.dart';
import '../../domain/entities/recommended_organization_entity.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../datasources/recommendation_remote_datasource.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  final RecommendationRemoteDataSource remote;

  RecommendationRepositoryImpl(this.remote);

  @override
  Future<List<RecommendedCourseEntity>> getRecommendedCourses() {
    return remote.getRecommendedCourses();
  }

  @override
  Future<List<RecommendedOrganizationEntity>> getRecommendedOrganizations() {
    return remote.getRecommendedOrganizations();
  }
}
