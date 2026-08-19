import '../../../recommendations/domain/entities/recommended_course_entity.dart';
import '../../../recommendations/domain/entities/recommended_organization_entity.dart';
import '../../../courses/domain/entities/course_entity.dart';
import '../../../organizations/domain/entities/organization_entity.dart';

sealed class HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<RecommendedCourseEntity>? recommendedCourses;
  final String? coursesError;
  final List<RecommendedOrganizationEntity>? recommendedOrganizations;
  final String? organizationsError;

  final bool isSearching;
  final String searchQuery;
  final List<CourseEntity>? searchCourses;
  final List<OrganizationEntity>? searchOrganizations;
  final String? searchCoursesError;
  final String? searchOrganizationsError;

  HomeLoaded({
    this.recommendedCourses,
    this.coursesError,
    this.recommendedOrganizations,
    this.organizationsError,
    this.isSearching = false,
    this.searchQuery = '',
    this.searchCourses,
    this.searchOrganizations,
    this.searchCoursesError,
    this.searchOrganizationsError,
  });

  HomeLoaded copyWith({
    List<RecommendedCourseEntity>? recommendedCourses,
    String? coursesError,
    List<RecommendedOrganizationEntity>? recommendedOrganizations,
    String? organizationsError,
    bool? isSearching,
    String? searchQuery,
    List<CourseEntity>? searchCourses,
    List<OrganizationEntity>? searchOrganizations,
    String? searchCoursesError,
    String? searchOrganizationsError,
  }) {
    return HomeLoaded(
      recommendedCourses: recommendedCourses ?? this.recommendedCourses,
      coursesError: coursesError ?? this.coursesError,
      recommendedOrganizations: recommendedOrganizations ?? this.recommendedOrganizations,
      organizationsError: organizationsError ?? this.organizationsError,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      searchCourses: searchCourses ?? this.searchCourses,
      searchOrganizations: searchOrganizations ?? this.searchOrganizations,
      searchCoursesError: searchCoursesError ?? this.searchCoursesError,
      searchOrganizationsError: searchOrganizationsError ?? this.searchOrganizationsError,
    );
  }
}