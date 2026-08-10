import '../entities/paginated_posts_entity.dart';
import '../entities/comment_entity.dart';

abstract class PostsRepository {
  Future<PaginatedPostsEntity> getOrganizationPosts(String orgSlug);
  Future<PaginatedPostsEntity> getCoursePosts(String courseSlug);
  Future<List<CommentEntity>> getComments(int postId);
  Future<CommentEntity> addComment(int postId, String content, {int? parentCommentId});
  Future<void> deleteComment(int postId, int commentId);
  Future<void> likeComment(int commentId);
  Future<void> unlikeComment(int commentId);
  Future<void> reactToPost(int postId, String reactionType);
}