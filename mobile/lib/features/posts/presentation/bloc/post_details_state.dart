import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/post_entity.dart';

abstract class PostDetailsState {}

class PostDetailsInitial extends PostDetailsState {}

class CommentsLoading extends PostDetailsState {}

class CommentsLoaded extends PostDetailsState {
  final List<CommentEntity> comments;
  final PostEntity post;
  CommentsLoaded({required this.comments, required this.post});
}

class CommentAdded extends PostDetailsState {
  final List<CommentEntity> comments;
  final PostEntity post;
  CommentAdded({required this.comments, required this.post});
}

class CommentDeleted extends PostDetailsState {
  final List<CommentEntity> comments;
  final PostEntity post;
  CommentDeleted({required this.comments, required this.post});
}

class PostDetailsError extends PostDetailsState {
  final String message;
  PostDetailsError(this.message);
}
class CommentSubmitting extends PostDetailsState {
  final List<CommentEntity> comments;
  final PostEntity post;
  CommentSubmitting({required this.comments, required this.post});
}