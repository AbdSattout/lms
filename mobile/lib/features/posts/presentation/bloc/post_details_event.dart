import '../../domain/entities/post_entity.dart';

abstract class PostDetailsEvent {}

class LoadComments extends PostDetailsEvent {
  final int postId;
  final PostEntity post;
  LoadComments({required this.postId, required this.post});
}

class AddCommentRequested extends PostDetailsEvent {
  final int postId;
  final String content;
  final int? parentCommentId;
  AddCommentRequested({required this.postId, required this.content, this.parentCommentId});
}

class DeleteCommentRequested extends PostDetailsEvent {
  final int commentId;
  DeleteCommentRequested({required this.commentId});
}

class ToggleCommentLike extends PostDetailsEvent {
  final int commentId;
  ToggleCommentLike(this.commentId);
}

class TogglePostReaction extends PostDetailsEvent {
  final int postId;
  final String reactionType;
  TogglePostReaction({required this.postId, required this.reactionType});
}