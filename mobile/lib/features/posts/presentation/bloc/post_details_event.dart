import '../../domain/entities/post_entity.dart';

abstract class PostDetailsEvent {}

class LoadComments extends PostDetailsEvent {
  final int postId;
  final PostEntity post;

  LoadComments({
    required this.postId,
    required this.post,
  });
}

class AddCommentRequested extends PostDetailsEvent {
  final int postId;
  final String content;
  final int? parentCommentId;

  AddCommentRequested({
    required this.postId,
    required this.content,
    this.parentCommentId,
  });
}

class DeleteCommentRequested extends PostDetailsEvent {
  final int postId;
  final int commentId;

  DeleteCommentRequested({
    required this.postId,
    required this.commentId,
  });
}

class LikeCommentRequested extends PostDetailsEvent {
  final int commentId;

  LikeCommentRequested(this.commentId);
}

class UnlikeCommentRequested extends PostDetailsEvent {
  final int commentId;

  UnlikeCommentRequested(this.commentId);
}

class ReactToPostRequested extends PostDetailsEvent {
  final int postId;
  final String reactionType;

  ReactToPostRequested({
    required this.postId,
    required this.reactionType,
  });
}