import '../../domain/entities/course_entity.dart';

abstract class CourseDetailsState {}

class CourseDetailsInitial extends CourseDetailsState {}

class CourseDetailsLoading extends CourseDetailsState {}

class CourseDetailsLoaded extends CourseDetailsState {
  final CourseEntity course;

  CourseDetailsLoaded(
      this.course,
      );
}

class CourseDetailsError extends CourseDetailsState {
  final String message;

  CourseDetailsError(
      this.message,
      );
}

/// One-off state so the UI can show a confirmation snackbar. The bloc
/// re-fetches the course right after this and emits CourseDetailsLoaded
/// again with updated progress info — this state is never left displayed.
class CourseEnrollSuccess extends CourseDetailsState {
  final CourseEnrollmentEntity enrollment;

  CourseEnrollSuccess(
      this.enrollment,
      );
}