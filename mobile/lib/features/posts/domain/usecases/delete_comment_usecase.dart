import '../repositories/posts_repository.dart';

class DeleteCommentUseCase {
  final PostsRepository repository;
  DeleteCommentUseCase(this.repository);
  Future<void> call(int commentId) => repository.deleteComment(commentId);
}