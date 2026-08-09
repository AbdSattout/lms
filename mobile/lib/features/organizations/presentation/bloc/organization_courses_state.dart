import '../../../courses/domain/entities/course_entity.dart';

abstract class OrganizationCoursesState {}

class OrganizationCoursesInitial extends OrganizationCoursesState {}

class OrganizationCoursesLoading extends OrganizationCoursesState {}

class OrganizationCoursesLoaded extends OrganizationCoursesState {
  final List<CourseEntity> courses;
  OrganizationCoursesLoaded(this.courses);
}

class OrganizationCoursesError extends OrganizationCoursesState {
  final String message;
  OrganizationCoursesError(this.message);
}