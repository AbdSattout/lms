import '../../domain/entities/course_entity.dart';

abstract class CourseDetailsState {}

class CourseDetailsInitial extends CourseDetailsState {}

class CourseDetailsLoading extends CourseDetailsState {}

class CourseDetailsLoaded extends CourseDetailsState {
  final CourseEntity course;
  final bool isStartingCourse;

  CourseDetailsLoaded(this.course, {this.isStartingCourse = false});
}

class CourseDetailsError extends CourseDetailsState {
  final String message;
  CourseDetailsError(this.message);
}

class CourseEnrollSuccess extends CourseDetailsState {
  final EnrollActionResultEntity result;
  CourseEnrollSuccess(this.result);
}

class CourseStartSuccess extends CourseDetailsState {
  final CourseEntity course;
  CourseStartSuccess(this.course);
}

class CourseDetailsActionError extends CourseDetailsState {
  final String message;
  CourseDetailsActionError(this.message);
}
