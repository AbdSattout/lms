import '../entities/paginated_posts_entity.dart';
import '../repositories/posts_repository.dart';

class GetOrganizationPostsUseCase {
  final PostsRepository repository;
  GetOrganizationPostsUseCase(this.repository);
  Future<PaginatedPostsEntity> call(String orgSlug) => repository.getOrganizationPosts(orgSlug);
}