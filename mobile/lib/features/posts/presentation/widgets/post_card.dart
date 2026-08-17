import 'package:flutter/material.dart';
import '../../../../core/markdown/markdown_content_view.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/relative_time.dart';
import '../../domain/entities/post_entity.dart';

class PostCard extends StatelessWidget {
  final PostEntity post;
  final VoidCallback onTap;
  final VoidCallback? onCommentTap;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: post.author.picture != null && post.author.picture!.isNotEmpty
                          ? NetworkImage(post.author.picture!)
                          : null,
                      child: post.author.picture == null || post.author.picture!.isEmpty
                          ? Icon(Icons.person, color: colors.primary, size: 20)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.author.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: colors.onSurface)),
                          if (post.createdAt != null) ...[
                            const SizedBox(height: 2),
                            Text(formatRelativeTime(post.createdAt), style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (post.title.isNotEmpty) ...[
                  Text(post.title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: colors.onSurface)),
                  const SizedBox(height: 8),
                ],

                MarkdownContentView(content: post.content),
                const SizedBox(height: 14),

                Row(
                  children: [
                    _ReactionSummary(
                      reactionCounts: post.reactionCounts,
                      viewerReaction: post.viewerReaction,
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: onCommentTap,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, size: 18, color: colors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text('${post.commentCount}', style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReactionSummary extends StatelessWidget {
  final dynamic reactionCounts;
  final String? viewerReaction;

  const _ReactionSummary({
    required this.reactionCounts,
    this.viewerReaction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final total = reactionCounts.total as int;

    final (emoji, label, color) = switch (viewerReaction) {
      'LIKE' => ('👍', 'إعجاب', const Color(0xff2563EB)),
      'LOVE' => ('❤️', 'حب', const Color(0xffD9534F)),
      'SUPPORT' => ('🤝', 'دعم', const Color(0xff2E7D53)),
      'CELEBRATE' => ('🎉', 'احتفال', const Color(0xffF2C94C)),
      'INSIGHTFUL' => ('💡', 'مفيد', const Color(0xff9B51E0)),
      _ => (null, null, null),
    };

    if (total == 0 && viewerReaction == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: viewerReaction != null
            ? color!.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null)
            Text(emoji, style: const TextStyle(fontSize: 14))
          else
            Icon(Icons.favorite_border_rounded, size: 16, color: colors.onSurfaceVariant),
          if (total > 0) ...[
            const SizedBox(width: 5),
            Text(
              '$total',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: viewerReaction != null ? color : colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}