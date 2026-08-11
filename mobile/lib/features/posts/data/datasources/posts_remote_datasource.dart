import '../../../../core/databases/api/api_consumer.dart';
import '../../../../core/databases/api/end_points.dart';
import '../models/paginated_posts_model.dart';
import '../models/comment_model.dart';

abstract class PostsRemoteDataSource {
  Future<PaginatedPostsModel> getOrganizationPosts(String orgSlug);
  Future<PaginatedPostsModel> getCoursePosts(int courseId);
  Future<List<CommentModel>> getComments(int postId);
  Future<CommentModel> addComment(
    int postId,
    String content, {
    int? parentCommentId,
  });
  Future<void> deleteComment(int commentId);
  Future<void> likeComment(int commentId);
  Future<void> unlikeComment(int commentId);
  Future<void> reactToPost(int postId, String reactionType);
}

class PostsRemoteDataSourceImpl implements PostsRemoteDataSource {
  final ApiConsumer api;

  PostsRemoteDataSourceImpl({required this.api});

  @override
  Future<PaginatedPostsModel> getOrganizationPosts(String orgSlug) async {
    final response = await api.get(EndPoints.organizationPosts(orgSlug));
    return PaginatedPostsModel.fromJson(response);
  }

  @override
  Future<PaginatedPostsModel> getCoursePosts(int courseId) async {
    final response = await api.get(EndPoints.coursePosts(courseId));
    return PaginatedPostsModel.fromJson(response);
  }

  @override
  Future<List<CommentModel>> getComments(int postId) async {
    final response = await api.get(EndPoints.postComments(postId));
    return (response as List<dynamic>)
        .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CommentModel> addComment(
    int postId,
    String content, {
    int? parentCommentId,
  }) async {
    final response = await api.post(
      EndPoints.postComments(postId),
      data: {'content': content, 'parentCommentId': parentCommentId},
    );
    return CommentModel.fromJson(response);
  }

  @override
  Future<void> deleteComment(int commentId) async {
    await api.delete(EndPoints.deleteComment(commentId));
  }

  @override
  Future<void> likeComment(int commentId) async {
    await api.post(EndPoints.commentLikes(commentId));
  }

  @override
  Future<void> unlikeComment(int commentId) async {
    await api.delete(EndPoints.commentLikes(commentId));
  }

  @override
  Future<void> reactToPost(int postId, String reactionType) async {
    await api.post(
      EndPoints.postLikes(postId),
      data: {'reactionType': reactionType},
    );
  }
}
