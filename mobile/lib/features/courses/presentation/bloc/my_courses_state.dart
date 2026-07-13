import '../../domain/entities/course_entity.dart';

abstract class MyCoursesState {}

class MyCoursesInitial extends MyCoursesState {}

class MyCoursesLoading extends MyCoursesState {}

class MyCoursesLoaded extends MyCoursesState {
  final List<CourseEntity> courses;

  MyCoursesLoaded(
      this.courses,
      );
}

class MyCoursesError extends MyCoursesState {
  final String message;

  MyCoursesError(
      this.message,
      );
}