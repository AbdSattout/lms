import '../entities/course_entity.dart';
import '../repositories/course_repository.dart';

class GetMyEnrollmentsUseCase {
  final CourseRepository repository;

  GetMyEnrollmentsUseCase(this.repository);

  Future<List<CourseEntity>> call() {
    return repository.getMyEnrollments();
  }
}