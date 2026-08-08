import '../repositories/course_repository.dart';

class UnenrollFromCourseUseCase {
  final CourseRepository repository;

  UnenrollFromCourseUseCase(this.repository);

  Future<void> call(int courseId) async {
    return repository.unenrollFromCourse(courseId);
  }
}