import '../entities/course_entity.dart';
import '../repositories/course_repository.dart';

class GetAllCoursesUseCase {
  final CourseRepository repository;

  GetAllCoursesUseCase(this.repository);

  Future<List<CourseEntity>> call() {
    return repository.getAllCourses();
  }
}