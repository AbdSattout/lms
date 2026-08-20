import '../../domain/entities/course_entity.dart';

sealed class AllCoursesState {}

class AllCoursesInitial extends AllCoursesState {}

class AllCoursesLoading extends AllCoursesState {}

class AllCoursesLoaded extends AllCoursesState {
  final List<CourseEntity> courses;
  AllCoursesLoaded(this.courses);
}

class AllCoursesEmpty extends AllCoursesState {}

class AllCoursesError extends AllCoursesState {
  final String message;
  AllCoursesError(this.message);
}