import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/markdown/markdown_content_view.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/relative_time.dart';
import '../../../reports/domain/entities/report_target.dart';
import '../../../reports/presentation/widgets/report_bottom_sheet.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../bloc/post_details_bloc.dart';
import '../bloc/post_details_event.dart';
import '../bloc/post_details_state.dart';

class PostDetailsPage extends StatefulWidget {
  final PostEntity post;
  final bool openComments;

  const PostDetailsPage({
    super.key,
    required this.post,
    this.openComments = false,
  });

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int? _replyingToCommentId;
  String? _replyingToAuthorName;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    if (widget.openComments) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToComments());
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToComments() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToAuthorName = null;
    });
  }

  void _startReply(CommentEntity comment) {
    setState(() {
      _replyingToCommentId = comment.id;
      _replyingToAuthorName = comment.author.name;
    });
  }

  void _sendComment(BuildContext context) {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    _hasChanges = true;
    context.read<PostDetailsBloc>().add(
      AddCommentRequested(
        postId: widget.post.id,
        content: text,
        parentCommentId: _replyingToCommentId,
      ),
    );
  }

  void _navigateBack(BuildContext context) {
    final bloc = context.read<PostDetailsBloc>();
    if (_hasChanges && bloc.currentPost != null) {
      Navigator.pop(context, bloc.currentPost);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _confirmDeleteComment(
    BuildContext context,
    int commentId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف التعليق'),
          content: const Text('هل أنت متأكد من أنك تريد حذف هذا التعليق؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );

    if (!context.mounted || confirmed != true) return;
    _hasChanges = true;
    context.read<PostDetailsBloc>().add(
      DeleteCommentRequested(commentId: commentId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PostDetailsBloc>(
      create: (_) =>
          sl<PostDetailsBloc>()
            ..add(LoadComments(postId: widget.post.id, post: widget.post)),
      child: Builder(
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('تفاصيل المنشور'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => _navigateBack(context),
              ),
              actions: [
                PopupMenuButton<_PostDetailsReportAction>(
                  tooltip: 'خيارات البلاغ',
                  icon: const Icon(Icons.more_horiz_rounded),
                  onSelected: (action) {
                    final title = widget.post.title.trim().isNotEmpty
                        ? widget.post.title.trim()
                        : 'منشور ${widget.post.author.name}';

                    switch (action) {
                      case _PostDetailsReportAction.post:
                        showReportBottomSheet(
                          context,
                          ReportTarget.post(
                            postId: widget.post.id,
                            organizationId: widget.post.organizationId,
                            userId: widget.post.author.id,
                            title: title,
                          ),
                        );
                        break;
                      case _PostDetailsReportAction.author:
                        showReportBottomSheet(
                          context,
                          ReportTarget.user(
                            userId: widget.post.author.id,
                            title: widget.post.author.name,
                          ),
                        );
                        break;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _PostDetailsReportAction.post,
                      child: Row(
                        children: [
                          Icon(Icons.outlined_flag_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('الإبلاغ عن المنشور'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: _PostDetailsReportAction.author,
                      child: Row(
                        children: [
                          Icon(Icons.person_off_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('الإبلاغ عن المستخدم'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            body: BlocConsumer<PostDetailsBloc, PostDetailsState>(
              listener: (context, state) {
                if (state is PostDetailsError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
                if (state is CommentAdded) {
                  _commentController.clear();
                  _cancelReply();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إضافة التعليق')),
                  );
                }
                if (state is CommentDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف التعليق')),
                  );
                }
              },
              builder: (context, state) {
                final comments = _getCommentsFromState(state);
                final currentPost = _getPostFromState(state) ?? widget.post;
                final isLoading =
                    state is CommentsLoading || state is PostDetailsInitial;
                final hasError = state is PostDetailsError && comments == null;

                return Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: () async {
                        context.read<PostDetailsBloc>().add(
                          LoadComments(
                            postId: currentPost.id,
                            post: currentPost,
                          ),
                        );
                      },
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _PostHeader(post: currentPost),
                            const SizedBox(height: 20),
                            _PostReactionBar(
                              post: currentPost,
                              onReaction: (type) {
                                _hasChanges = true;
                                context.read<PostDetailsBloc>().add(
                                  TogglePostReaction(
                                    postId: currentPost.id,
                                    reactionType: type,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            _CommentsSectionHeader(
                              count:
                                  comments?.length ?? currentPost.commentCount,
                            ),
                            const SizedBox(height: 16),
                            if (isLoading)
                              _CommentsLoading()
                            else if (hasError)
                              _CommentsError(
                                message: state.message,
                                onRetry: () =>
                                    context.read<PostDetailsBloc>().add(
                                      LoadComments(
                                        postId: currentPost.id,
                                        post: currentPost,
                                      ),
                                    ),
                              )
                            else if (comments != null)
                              _CommentsList(
                                comments: comments,
                                post: currentPost,
                                onReply: _startReply,
                                onToggleLike: (id) => context
                                    .read<PostDetailsBloc>()
                                    .add(ToggleCommentLike(id)),
                                onDelete: (id) =>
                                    _confirmDeleteComment(context, id),
                                onReport: (comment) {
                                  showReportBottomSheet(
                                    context,
                                    ReportTarget.comment(
                                      commentId: comment.id,
                                      postId: currentPost.id,
                                      organizationId:
                                          currentPost.organizationId,
                                      userId: comment.author.id,
                                      title: 'تعليق ${comment.author.name}',
                                    ),
                                  );
                                },
                              ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    _CommentComposer(
                      controller: _commentController,
                      replyingTo: _replyingToAuthorName,
                      onCancelReply: _cancelReply,
                      onSend: () => _sendComment(context),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<CommentEntity>? _getCommentsFromState(PostDetailsState state) {
    if (state is CommentsLoaded) return state.comments;
    if (state is CommentAdded) return state.comments;
    if (state is CommentDeleted) return state.comments;
    return null;
  }

  PostEntity? _getPostFromState(PostDetailsState state) {
    if (state is CommentsLoaded) return state.post;
    if (state is CommentAdded) return state.post;
    if (state is CommentDeleted) return state.post;
    return null;
  }
}

enum _PostDetailsReportAction { post, author }

class _PostHeader extends StatelessWidget {
  final PostEntity post;
  const _PostHeader({required this.post});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasPicture =
        post.author.picture != null && post.author.picture!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: hasPicture
                  ? NetworkImage(post.author.picture!)
                  : null,
              child: !hasPicture
                  ? Icon(Icons.person_rounded, color: colors.primary, size: 22)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.author.name,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                  if (post.createdAt != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      formatRelativeTime(post.createdAt),
                      style: TextStyle(
                        fontSize: 11.5,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (post.title.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            post.title,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: colors.onSurface,
              height: 1.3,
            ),
          ),
        ],
        const SizedBox(height: 12),
        MarkdownContentView(content: post.content),
      ],
    );
  }
}

class _PostReactionBar extends StatelessWidget {
  final PostEntity post;
  final Function(String reactionType) onReaction;

  const _PostReactionBar({required this.post, required this.onReaction});

  void _showReactionPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'اختر تفاعلك',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _PickerReaction(
                      emoji: '👍',
                      label: 'إعجاب',
                      isSelected: post.viewerReaction == 'LIKE',
                      onTap: () {
                        Navigator.pop(sheetContext);
                        onReaction('LIKE');
                      },
                    ),
                    _PickerReaction(
                      emoji: '❤️',
                      label: 'حب',
                      isSelected: post.viewerReaction == 'LOVE',
                      onTap: () {
                        Navigator.pop(sheetContext);
                        onReaction('LOVE');
                      },
                    ),
                    _PickerReaction(
                      emoji: '🤝',
                      label: 'دعم',
                      isSelected: post.viewerReaction == 'SUPPORT',
                      onTap: () {
                        Navigator.pop(sheetContext);
                        onReaction('SUPPORT');
                      },
                    ),
                    _PickerReaction(
                      emoji: '🎉',
                      label: 'احتفال',
                      isSelected: post.viewerReaction == 'CELEBRATE',
                      onTap: () {
                        Navigator.pop(sheetContext);
                        onReaction('CELEBRATE');
                      },
                    ),
                    _PickerReaction(
                      emoji: '💡',
                      label: 'مفيد',
                      isSelected: post.viewerReaction == 'INSIGHTFUL',
                      onTap: () {
                        Navigator.pop(sheetContext);
                        onReaction('INSIGHTFUL');
                      },
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

  @override
  Widget build(BuildContext context) {
    final viewerReaction = post.viewerReaction;
    final totalReactions = post.reactionCounts.total;

    final currentEmoji = switch (viewerReaction) {
      'LIKE' => '👍',
      'LOVE' => '❤️',
      'SUPPORT' => '🤝',
      'CELEBRATE' => '🎉',
      'INSIGHTFUL' => '💡',
      _ => '👍',
    };

    final currentLabel = switch (viewerReaction) {
      'LIKE' => 'إعجاب',
      'LOVE' => 'حب',
      'SUPPORT' => 'دعم',
      'CELEBRATE' => 'احتفال',
      'INSIGHTFUL' => 'مفيد',
      _ => 'إعجاب',
    };

    return GestureDetector(
      onLongPress: () => _showReactionPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: viewerReaction != null
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: viewerReaction != null
                ? Theme.of(context).colorScheme.primary.withOpacity(0.35)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(currentEmoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              currentLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (totalReactions > 0) ...[
              const SizedBox(width: 8),
              Text(
                '$totalReactions',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PickerReaction extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PickerReaction({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: isSelected ? 1.5 : 0,
              ),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentsSectionHeader extends StatelessWidget {
  final int count;
  const _CommentsSectionHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.chat_bubble_outline_rounded,
            size: 18,
            color: colors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'التعليقات',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: colors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _CommentsList extends StatelessWidget {
  final List<CommentEntity> comments;
  final PostEntity post;
  final Function(CommentEntity) onReply;
  final Function(int) onToggleLike;
  final Function(int) onDelete;
  final Function(CommentEntity) onReport;

  const _CommentsList({
    required this.comments,
    required this.post,
    required this.onReply,
    required this.onToggleLike,
    required this.onDelete,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) return const _EmptyComments();

    final topLevel = comments.where((c) => c.parentCommentId == null).toList();

    return Column(
      children: topLevel.map((comment) {
        return _CommentNode(
          comment: comment,
          post: post,
          allComments: comments,
          depth: 0,
          onReply: onReply,
          onToggleLike: onToggleLike,
          onDelete: onDelete,
          onReport: onReport,
        );
      }).toList(),
    );
  }
}

class _CommentNode extends StatefulWidget {
  final CommentEntity comment;
  final PostEntity post;
  final List<CommentEntity> allComments;
  final int depth;
  final Function(CommentEntity) onReply;
  final Function(int) onToggleLike;
  final Function(int) onDelete;
  final Function(CommentEntity) onReport;

  const _CommentNode({
    required this.comment,
    required this.post,
    required this.allComments,
    required this.depth,
    required this.onReply,
    required this.onToggleLike,
    required this.onDelete,
    required this.onReport,
  });

  @override
  State<_CommentNode> createState() => _CommentNodeState();
}

class _CommentNodeState extends State<_CommentNode> {
  bool _repliesExpanded = false;

  List<CommentEntity> get _children => widget.allComments
      .where((c) => c.parentCommentId == widget.comment.id)
      .toList();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasChildren = _children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CommentTile(
          comment: widget.comment,
          isReply: widget.depth > 0,
          depth: widget.depth,
          onReply: () => widget.onReply(widget.comment),
          onToggleLike: () => widget.onToggleLike(widget.comment.id),
          onDelete: widget.comment.viewerComment
              ? () => widget.onDelete(widget.comment.id)
              : null,
          onReport: () => widget.onReport(widget.comment),
        ),
        if (hasChildren)
          Padding(
            padding: EdgeInsets.only(
              right: (widget.depth + 1) * 52.0,
              bottom: _repliesExpanded ? 8 : 12,
            ),
            child: GestureDetector(
              onTap: () => setState(() => _repliesExpanded = !_repliesExpanded),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _repliesExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _repliesExpanded
                        ? 'إخفاء الردود'
                        : 'عرض ${widget.comment.repliesCount} ${widget.comment.repliesCount == 1 ? 'رد' : 'ردود'}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_repliesExpanded && hasChildren)
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: Column(
              children: _children
                  .map(
                    (child) => _CommentNode(
                      comment: child,
                      post: widget.post,
                      allComments: widget.allComments,
                      depth: widget.depth + 1,
                      onReply: widget.onReply,
                      onToggleLike: widget.onToggleLike,
                      onDelete: widget.onDelete,
                      onReport: widget.onReport,
                    ),
                  )
                  .toList(),
            ),
          ),
        if (!hasChildren) const SizedBox(height: 4),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentEntity comment;
  final bool isReply;
  final int depth;
  final VoidCallback onReply;
  final VoidCallback onToggleLike;
  final VoidCallback? onDelete;
  final VoidCallback onReport;

  const _CommentTile({
    required this.comment,
    required this.isReply,
    required this.depth,
    required this.onReply,
    required this.onToggleLike,
    required this.onReport,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasPicture =
        comment.author.picture != null &&
        comment.author.picture!.trim().isNotEmpty;
    final hasLiked = comment.viewerReaction != null;

    return Padding(
      padding: EdgeInsets.only(bottom: isReply ? 8 : 14, right: depth * 52.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: isReply ? 14 : 18,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: hasPicture
                ? NetworkImage(comment.author.picture!)
                : null,
            child: !hasPicture
                ? Icon(
                    Icons.person_rounded,
                    size: isReply ? 14 : 18,
                    color: colors.primary,
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withOpacity(0.4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.author.name,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                  if (comment.createdAt != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      formatRelativeTime(comment.createdAt),
                      style: TextStyle(
                        fontSize: 10.5,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    comment.content,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.5,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _CommentAction(
                        icon: Icons.reply_rounded,
                        label: 'رد',
                        onTap: onReply,
                      ),
                      const SizedBox(width: 16),
                      _CommentAction(
                        icon: hasLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        iconColor: hasLiked ? Colors.red : null,
                        label: comment.likeCount > 0
                            ? '${comment.likeCount}'
                            : '',
                        onTap: onToggleLike,
                      ),
                      const SizedBox(width: 16),
                      _CommentAction(
                        icon: Icons.outlined_flag_rounded,
                        label: 'بلاغ',
                        onTap: onReport,
                      ),
                      if (onDelete != null) ...[
                        const Spacer(),
                        _CommentAction(
                          icon: Icons.delete_outline_rounded,
                          label: '',
                          onTap: onDelete!,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final VoidCallback onTap;

  const _CommentAction({
    required this.icon,
    required this.label,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color:
                    iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CommentsLoading extends StatelessWidget {
  const _CommentsLoading();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'جاري تحميل التعليقات...',
              style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CommentsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 26,
                color: colors.error,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'تعذر تحميل التعليقات',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('إعادة المحاولة'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyComments extends StatelessWidget {
  const _EmptyComments();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 26,
              color: colors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'لا توجد تعليقات بعد',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'كن أول من يعلق على هذا المنشور',
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _CommentComposer extends StatelessWidget {
  final TextEditingController controller;
  final String? replyingTo;
  final VoidCallback onCancelReply;
  final VoidCallback onSend;

  const _CommentComposer({
    required this.controller,
    required this.replyingTo,
    required this.onCancelReply,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isReplying = replyingTo != null;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Material(
        elevation: 8,
        color: colors.surface,
        shadowColor: Colors.black.withOpacity(0.08),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isReplying)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: colors.primary.withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.reply_rounded,
                          size: 15,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'الرد على $replyingTo',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors.primary,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: onCancelReply,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: colors.onSurfaceVariant.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.newline,
                        style: TextStyle(fontSize: 14, color: colors.onSurface),
                        decoration: InputDecoration(
                          hintText: isReplying
                              ? 'اكتب ردك...'
                              : 'اكتب تعليقاً...',
                          hintStyle: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 13.5,
                          ),
                          filled: true,
                          fillColor: colors.surfaceContainerHighest.withOpacity(
                            0.5,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller,
                      builder: (context, value, _) {
                        final hasText = value.text.trim().isNotEmpty;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: IconButton.filled(
                            onPressed: hasText ? onSend : null,
                            icon: const Icon(Icons.send_rounded, size: 18),
                            style: IconButton.styleFrom(
                              backgroundColor: hasText
                                  ? colors.primary
                                  : colors.surfaceContainerHighest,
                              foregroundColor: hasText
                                  ? colors.onPrimary
                                  : colors.onSurfaceVariant,
                              minimumSize: const Size(44, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        );
                      },
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
