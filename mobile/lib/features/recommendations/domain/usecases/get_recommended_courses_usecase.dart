import '../entities/recommended_course_entity.dart';
import '../repositories/recommendation_repository.dart';

class GetRecommendedCoursesUseCase {
  final RecommendationRepository repository;

  GetRecommendedCoursesUseCase(this.repository);

  Future<List<RecommendedCourseEntity>> call() {
    return repository.getRecommendedCourses();
  }
}
