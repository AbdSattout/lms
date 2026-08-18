abstract class CourseDetailsEvent {}

class GetCourseDetailsEvent extends CourseDetailsEvent {
  final int? id;
  final String? orgSlug;
  final String? courseSlug;

  GetCourseDetailsEvent({this.id, this.orgSlug, this.courseSlug})
    : assert(
        id != null || (orgSlug != null && courseSlug != null),
        'Provide either an id, or both orgSlug and courseSlug',
      );
}

class EnrollEvent extends CourseDetailsEvent {
  final int courseId;
  EnrollEvent(this.courseId);
}

class StartCourseEvent extends CourseDetailsEvent {
  final int courseId;
  StartCourseEvent(this.courseId);
}
