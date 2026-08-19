import '../../../courses/domain/entities/course_entity.dart';
import '../repositories/home_repository.dart';

class SearchCoursesUseCase {
  final HomeRepository repository;
  SearchCoursesUseCase(this.repository);
  Future<List<CourseEntity>> call(String query) => repository.searchCourses(query);
}