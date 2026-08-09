import '../../../courses/domain/entities/course_entity.dart';
import '../repositories/organization_repository.dart';

class GetOrganizationCoursesUseCase {
  final OrganizationRepository repository;

  GetOrganizationCoursesUseCase(this.repository);

  Future<List<CourseEntity>> call(String slug) {
    return repository.getOrganizationCourses(slug);
  }
}