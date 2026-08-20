import '../../domain/entities/comment_entity.dart';
import 'post_author_model.dart';
import 'reaction_counts_model.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.content,
    required super.author,
    super.parentCommentId,
    required super.likeCount,
    super.repliesCount,
    required super.reactionCounts,
    super.viewerReaction,
    super.viewerComment,
    super.createdAt,
    super.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final baseEntity = json['baseEntity'] as Map<String, dynamic>?;
    return CommentModel(
      id: json['id'] as int,
      content: json['content'] as String? ?? '',
      author: PostAuthorModel.fromJson(json['author'] as Map<String, dynamic>),
      parentCommentId: json['parentCommentId'] as int?,
      likeCount: json['likeCount'] as int? ?? 0,
      repliesCount: json['repliesCount'] as int? ?? 0,
      reactionCounts: ReactionCountsModel.fromJson(json['reactionCounts'] as Map<String, dynamic>? ?? {}),
      viewerReaction: json['viewerReaction'] as String?,
      viewerComment: json['viewerComment'] as bool? ?? false,
      createdAt: baseEntity?['createdAt'] as String?,
      updatedAt: baseEntity?['updatedAt'] as String?,
    );
  }
}