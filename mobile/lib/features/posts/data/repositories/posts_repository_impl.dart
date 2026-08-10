import '../../domain/entities/paginated_posts_entity.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/posts_repository.dart';
import '../datasources/posts_remote_datasource.dart';

class PostsRepositoryImpl implements PostsRepository {
  final PostsRemoteDataSource remoteDataSource;

  PostsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PaginatedPostsEntity> getOrganizationPosts(String orgSlug) async {
    return await remoteDataSource.getOrganizationPosts(orgSlug);
  }

  @override
  Future<PaginatedPostsEntity> getCoursePosts(int courseId) async {
    return await remoteDataSource.getCoursePosts(courseId);
  }

  @override
  Future<List<CommentEntity>> getComments(int postId) async {
    return await remoteDataSource.getComments(postId);
  }

  @override
  Future<CommentEntity> addComment(
    int postId,
    String content, {
    int? parentCommentId,
  }) async {
    return await remoteDataSource.addComment(
      postId,
      content,
      parentCommentId: parentCommentId,
    );
  }

  @override
  Future<void> deleteComment(int postId, int commentId) async {
    await remoteDataSource.deleteComment(postId, commentId);
  }

  @override
  Future<void> likeComment(int commentId) async {
    await remoteDataSource.likeComment(commentId);
  }

  @override
  Future<void> unlikeComment(int commentId) async {
    await remoteDataSource.unlikeComment(commentId);
  }

  @override
  Future<void> reactToPost(int postId, String reactionType) async {
    await remoteDataSource.reactToPost(postId, reactionType);
  }
}
