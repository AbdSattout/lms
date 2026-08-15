import '../../recommendations/domain/entities/recommended_course_entity.dart';
import '../../recommendations/domain/entities/recommended_organization_entity.dart';

abstract class HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<RecommendedCourseEntity>? recommendedCourses;
  final String? coursesError;

  final List<RecommendedOrganizationEntity>? recommendedOrganizations;
  final String? organizationsError;

  HomeLoaded({
    this.recommendedCourses,
    this.coursesError,
    this.recommendedOrganizations,
    this.organizationsError,
  });
}
