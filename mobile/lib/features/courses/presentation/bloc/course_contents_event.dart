abstract class CourseContentsEvent {}

class GetCourseContentsEvent extends CourseContentsEvent {
  final int courseId;
  GetCourseContentsEvent(this.courseId);
}