import '../entities/comment_entity.dart';
import '../repositories/posts_repository.dart';

class AddCommentUseCase {
  final PostsRepository repository;
  AddCommentUseCase(this.repository);
  Future<CommentEntity> call(int postId, String content, {int? parentCommentId}) =>
      repository.addComment(postId, content, parentCommentId: parentCommentId);
}