import '../entities/recommended_course_entity.dart';
import '../entities/recommended_organization_entity.dart';

abstract class RecommendationRepository {
  Future<List<RecommendedCourseEntity>> getRecommendedCourses();

  Future<List<RecommendedOrganizationEntity>> getRecommendedOrganizations();
}
