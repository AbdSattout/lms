import '../../domain/entities/course_entity.dart';

abstract class CourseDetailsEvent {}

class GetCourseDetailsEvent extends CourseDetailsEvent {
  final int? id;
  final String? orgSlug;
  final String? courseSlug;

  final CourseProgressEntity? knownProgress;

  GetCourseDetailsEvent({
    this.id,
    this.orgSlug,
    this.courseSlug,
    this.knownProgress,
  }) : assert(
  id != null || (orgSlug != null && courseSlug != null),
  'Provide either an id, or both orgSlug and courseSlug',
  );
}

class EnrollEvent extends CourseDetailsEvent {
  final int courseId;

  EnrollEvent(this.courseId);
}