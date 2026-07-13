import '../entities/course_entity.dart';
import '../repositories/course_repository.dart';

class GetCourseByIdUseCase {
  final CourseRepository repository;

  GetCourseByIdUseCase(this.repository);

  Future<CourseEntity> call(int id) {
    return repository.getCourseById(id);
  }
}