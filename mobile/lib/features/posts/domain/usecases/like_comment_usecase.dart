import '../repositories/posts_repository.dart';

class LikeCommentUseCase {
  final PostsRepository repository;
  LikeCommentUseCase(this.repository);
  Future<void> call(int commentId) => repository.likeComment(commentId);
}