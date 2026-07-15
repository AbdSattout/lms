import '../entities/course_entity.dart';
import '../repositories/course_repository.dart';

class GetCourseBySlugUseCase {
  final CourseRepository repository;

  GetCourseBySlugUseCase(this.repository);

  Future<CourseEntity> call({
    required String orgSlug,
    required String courseSlug,
  }) {
    return repository.getCourseBySlug(
      orgSlug: orgSlug,
      courseSlug: courseSlug,
    );
  }
}