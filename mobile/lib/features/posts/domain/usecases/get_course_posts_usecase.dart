import '../entities/paginated_posts_entity.dart';
import '../repositories/posts_repository.dart';

class GetCoursePostsUseCase {
  final PostsRepository repository;
  GetCoursePostsUseCase(this.repository);
  Future<PaginatedPostsEntity> call(String courseSlug) => repository.getCoursePosts(courseSlug);
}