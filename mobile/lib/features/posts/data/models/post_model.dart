import '../../domain/entities/post_entity.dart';
import '../../domain/entities/reaction_counts_entity.dart';
import 'post_author_model.dart';
import 'reaction_counts_model.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.title,
    required super.content,
    required super.author,
    required super.organizationId,
    super.courseId,
    required super.commentCount,
    required super.likeCount,
    required super.reactionCounts,
    super.viewerReaction,
    super.createdAt,
    super.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final baseEntity = json['baseEntity'] as Map<String, dynamic>?;
    return PostModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      author: PostAuthorModel.fromJson(json['author'] as Map<String, dynamic>),
      organizationId: json['organizationId'] as int,
      courseId: json['courseId'] as int?,
      commentCount: json['commentCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      reactionCounts: ReactionCountsModel.fromJson(json['reactionCounts'] as Map<String, dynamic>? ?? {}),
      viewerReaction: json['viewerReaction'] as String?,
      createdAt: baseEntity?['createdAt'] as String?,
      updatedAt: baseEntity?['updatedAt'] as String?,
    );
  }
  PostModel copyWith({
    ReactionCountsEntity? reactionCounts,
    int? commentCount,
    int? likeCount,
    String? viewerReaction,
    bool clearViewerReaction = false,
  }) {
    return PostModel(
      id: id,
      title: title,
      content: content,
      author: author,
      organizationId: organizationId,
      courseId: courseId,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      reactionCounts: reactionCounts ?? this.reactionCounts,
      viewerReaction: clearViewerReaction ? null : (viewerReaction ?? this.viewerReaction),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}