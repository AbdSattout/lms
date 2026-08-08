abstract class CourseContentsEvent {}

class GetCourseContentsEvent extends CourseContentsEvent {
  final int courseId;
  GetCourseContentsEvent(this.courseId);
}
class UnenrollFromCourseEvent extends CourseContentsEvent {
  final int courseId;
  UnenrollFromCourseEvent(this.courseId);
}