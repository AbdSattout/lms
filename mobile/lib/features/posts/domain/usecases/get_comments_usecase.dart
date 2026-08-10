import '../entities/comment_entity.dart';
import '../repositories/posts_repository.dart';

class GetCommentsUseCase {
  final PostsRepository repository;
  GetCommentsUseCase(this.repository);
  Future<List<CommentEntity>> call(int postId) => repository.getComments(postId);
}