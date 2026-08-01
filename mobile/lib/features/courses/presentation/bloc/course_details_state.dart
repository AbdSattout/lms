import '../../domain/entities/course_entity.dart';

abstract class CourseDetailsState {}

class CourseDetailsInitial extends CourseDetailsState {}

class CourseDetailsLoading extends CourseDetailsState {}

class CourseDetailsLoaded extends CourseDetailsState {
  final CourseEntity course;
  CourseDetailsLoaded(this.course);
}

class CourseDetailsError extends CourseDetailsState {
  final String message;
  CourseDetailsError(this.message);
}
class CourseEnrollSuccess extends CourseDetailsState {
  final EnrollActionResultEntity result;
  CourseEnrollSuccess(this.result);
}