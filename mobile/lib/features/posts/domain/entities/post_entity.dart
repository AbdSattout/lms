import 'post_author_entity.dart';
import 'reaction_counts_entity.dart';

class PostEntity {
  final int id;
  final String title;
  final String content;
  final PostAuthorEntity author;
  final int organizationId;
  final int? courseId;
  final int commentCount;
  final int likeCount;
  final ReactionCountsEntity reactionCounts;
  final String? createdAt;
  final String? updatedAt;

  const PostEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.organizationId,
    this.courseId,
    required this.commentCount,
    required this.likeCount,
    required this.reactionCounts,
    this.createdAt,
    this.updatedAt,
  });
}