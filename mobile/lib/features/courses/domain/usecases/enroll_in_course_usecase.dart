import '../entities/course_entity.dart';
import '../repositories/course_repository.dart';

class EnrollInCourseUseCase {
  final CourseRepository repository;

  EnrollInCourseUseCase(this.repository);

  Future<CourseEnrollmentEntity> call(int courseId) {
    return repository.enrollInCourse(courseId);
  }
}