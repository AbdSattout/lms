import '../../domain/entities/course_entity.dart';

abstract class CourseContentsState {}

class CourseContentsLoading extends CourseContentsState {}

class CourseContentsLoaded extends CourseContentsState {
  final CourseEntity course;
  CourseContentsLoaded(this.course);
}

class CourseContentsError extends CourseContentsState {
  final String message;
  CourseContentsError(this.message);
}
class CourseUnenrolled extends CourseContentsState {
  final String message;
  CourseUnenrolled(this.message);
}