import '../../courses/domain/entities/course_entity.dart';
import '../../organizations/domain/entities/organization_entity.dart';

abstract class HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<CourseEntity>? courses;
  final String? coursesError;

  final List<OrganizationEntity>? organizations;
  final String? organizationsError;
  final Map<int, CourseEntity> enrolledCoursesById;

  HomeLoaded({
    this.courses,
    this.coursesError,
    this.organizations,
    this.organizationsError,
    this.enrolledCoursesById = const {},
  });
}