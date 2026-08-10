import 'post_author_entity.dart';
import 'reaction_counts_entity.dart';

class CommentEntity {
  final int id;
  final String content;
  final PostAuthorEntity author;
  final int? parentCommentId;
  final int likeCount;
  final ReactionCountsEntity reactionCounts;
  final String? createdAt;
  final String? updatedAt;

  const CommentEntity({
    required this.id,
    required this.content,
    required this.author,
    this.parentCommentId,
    required this.likeCount,
    required this.reactionCounts,
    this.createdAt,
    this.updatedAt,
  });

  bool get isReply => parentCommentId != null;
}