import '../repositories/posts_repository.dart';

class UnlikeCommentUseCase {
  final PostsRepository repository;
  UnlikeCommentUseCase(this.repository);
  Future<void> call(int commentId) => repository.unlikeComment(commentId);
}