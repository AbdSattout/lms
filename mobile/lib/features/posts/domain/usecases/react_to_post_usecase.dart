import '../repositories/posts_repository.dart';

class ReactToPostUseCase {
  final PostsRepository repository;
  ReactToPostUseCase(this.repository);
  Future<void> call(int postId, String reactionType) => repository.reactToPost(postId, reactionType);
}