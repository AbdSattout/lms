import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/markdown/markdown_content_view.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToComments();
      });
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PostDetailsBloc>(
      create: (_) => sl<PostDetailsBloc>()
        ..add(LoadComments(postId: widget.post.id, post: widget.post)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            final bloc = context.read<PostDetailsBloc>();
            if (_hasChanges && bloc.currentPost != null) {
              Navigator.pop(context, bloc.currentPost);
            } else {
              Navigator.pop(context);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('تفاصيل المنشور'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () {
                  final bloc = context.read<PostDetailsBloc>();
                  if (_hasChanges && bloc.currentPost != null) {
                    Navigator.pop(context, bloc.currentPost);
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            body: BlocConsumer<PostDetailsBloc, PostDetailsState>(
              listener: (context, state) {
                if (state is PostDetailsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
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

                final isLoadingComments =
                    state is CommentsLoading || state is PostDetailsInitial;

                return Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: () async {
                        context.read<PostDetailsBloc>().add(
                          LoadComments(postId: currentPost.id, post: currentPost),
                        );
                      },
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAuthorHeader(context, currentPost),
                            const SizedBox(height: 16),
                            if (currentPost.title.isNotEmpty) ...[
                              Text(
                                currentPost.title,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],
                            MarkdownContentView(content: currentPost.content),
                            const SizedBox(height: 20),
                            _buildReactionBar(context, currentPost),
                            const SizedBox(height: 20),
                            Divider(color: Theme.of(context).colorScheme.outlineVariant),
                            const SizedBox(height: 20),
                            _buildCommentsHeader(context, currentPost, comments),
                            const SizedBox(height: 16),
                            if (isLoadingComments)
                              _buildCommentsLoading(context)
                            else if (state is PostDetailsError && comments == null)
                              _buildCommentsError(context)
                            else
                              _buildCommentsList(context, comments ?? const [], currentPost),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _buildCommentInput(context),
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

  Widget _buildAuthorHeader(BuildContext context, PostEntity post) {
    final colors = Theme.of(context).colorScheme;
    final hasPicture = post.author.picture != null && post.author.picture!.trim().isNotEmpty;

    return Row(children: [
      CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.primaryLight,
        backgroundImage: hasPicture ? NetworkImage(post.author.picture!) : null,
        child: !hasPicture ? Icon(Icons.person_rounded, color: colors.primary) : null,
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(post.author.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: colors.onSurface)),
          const SizedBox(height: 3),
          Text('منشور', style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
        ]),
      ),
    ]);
  }

  Widget _buildReactionBar(BuildContext context, PostEntity post) {
    final reactions = post.reactionCounts;
    return Wrap(spacing: 8, runSpacing: 8, children: [
      _ReactionButton(emoji: '👍', label: 'إعجاب', count: reactions.like, onTap: () {
        _hasChanges = true;
        context.read<PostDetailsBloc>().add(ReactToPostRequested(postId: post.id, reactionType: 'LIKE'));
      }),
      _ReactionButton(emoji: '❤️', label: 'حب', count: reactions.love, onTap: () {
        _hasChanges = true;
        context.read<PostDetailsBloc>().add(ReactToPostRequested(postId: post.id, reactionType: 'LOVE'));
      }),
      _ReactionButton(emoji: '🤝', label: 'دعم', count: reactions.support, onTap: () {
        _hasChanges = true;
        context.read<PostDetailsBloc>().add(ReactToPostRequested(postId: post.id, reactionType: 'SUPPORT'));
      }),
      _ReactionButton(emoji: '🎉', label: 'احتفال', count: reactions.celebrate, onTap: () {
        _hasChanges = true;
        context.read<PostDetailsBloc>().add(ReactToPostRequested(postId: post.id, reactionType: 'CELEBRATE'));
      }),
      _ReactionButton(emoji: '💡', label: 'مفيد', count: reactions.insightful, onTap: () {
        _hasChanges = true;
        context.read<PostDetailsBloc>().add(ReactToPostRequested(postId: post.id, reactionType: 'INSIGHTFUL'));
      }),
    ]);
  }

  Widget _buildCommentsHeader(BuildContext context, PostEntity post, List<CommentEntity>? comments) {
    final colors = Theme.of(context).colorScheme;
    final count = comments?.length ?? post.commentCount;
    return Row(children: [
      Icon(Icons.chat_bubble_outline_rounded, size: 21, color: colors.primary),
      const SizedBox(width: 8),
      Text('التعليقات', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: colors.onSurface)),
      const SizedBox(width: 6),
      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: colors.primary.withOpacity(.10), borderRadius: BorderRadius.circular(10)), child: Text('$count', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: colors.primary))),
    ]);
  }

  Widget _buildCommentsLoading(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(padding: const EdgeInsets.symmetric(vertical: 40), child: Center(child: Column(children: [
      CircularProgressIndicator(color: colors.primary),
      const SizedBox(height: 12),
      Text('جاري تحميل التعليقات...', style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
    ])));
  }

  Widget _buildCommentsError(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(padding: const EdgeInsets.symmetric(vertical: 30), child: Center(child: Column(children: [
      Icon(Icons.error_outline_rounded, size: 42, color: colors.error),
      const SizedBox(height: 10),
      Text('تعذر تحميل التعليقات', style: TextStyle(fontWeight: FontWeight.w700, color: colors.onSurface)),
      const SizedBox(height: 12),
      OutlinedButton(onPressed: () {
        context.read<PostDetailsBloc>().add(LoadComments(postId: widget.post.id, post: widget.post));
      }, child: const Text('إعادة المحاولة')),
    ])));
  }

  Widget _buildCommentsList(BuildContext context, List<CommentEntity> comments, PostEntity post) {
    if (comments.isEmpty) return _buildEmptyComments(context);

    final topLevel = comments.where((c) => c.parentCommentId == null).toList();
    final replies = comments.where((c) => c.parentCommentId != null).toList();

    return Column(
      children: topLevel.map((comment) {
        final commentReplies = replies.where((r) => r.parentCommentId == comment.id).toList();
        return Column(children: [
          _CommentTile(comment: comment, onReply: () => _startReply(comment), onDelete: () => _confirmDeleteComment(context, post.id, comment.id), onLike: () => context.read<PostDetailsBloc>().add(LikeCommentRequested(comment.id)), onUnlike: () => context.read<PostDetailsBloc>().add(UnlikeCommentRequested(comment.id))),
          ...commentReplies.map((reply) => _CommentTile(comment: reply, onReply: () => _startReply(reply), onDelete: () => _confirmDeleteComment(context, post.id, reply.id), onLike: () => context.read<PostDetailsBloc>().add(LikeCommentRequested(reply.id)), onUnlike: () => context.read<PostDetailsBloc>().add(UnlikeCommentRequested(reply.id)))),
        ]);
      }).toList(),
    );
  }

  Widget _buildEmptyComments(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32), child: Column(children: [
      Icon(Icons.chat_bubble_outline_rounded, size: 48, color: colors.onSurfaceVariant.withOpacity(.5)),
      const SizedBox(height: 12),
      Text('لا توجد تعليقات بعد', style: TextStyle(fontWeight: FontWeight.w700, color: colors.onSurfaceVariant)),
      const SizedBox(height: 4),
      Text('كن أول من يعلق على هذا المنشور', style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
    ]));
  }

  Widget _buildCommentInput(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isReplying = _replyingToAuthorName != null;
    return Material(elevation: 12, color: colors.surface, child: SafeArea(top: false, child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), child: Column(mainAxisSize: MainAxisSize.min, children: [
      if (isReplying) Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: colors.primary.withOpacity(.08), borderRadius: BorderRadius.circular(10)), child: Row(children: [
        Icon(Icons.reply_rounded, size: 16, color: colors.primary),
        const SizedBox(width: 7),
        Expanded(child: Text('الرد على $_replyingToAuthorName', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary))),
        IconButton(onPressed: _cancelReply, icon: Icon(Icons.close_rounded, size: 18, color: colors.onSurfaceVariant), visualDensity: VisualDensity.compact, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
      ])),
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(child: TextField(controller: _commentController, minLines: 1, maxLines: 4, textInputAction: TextInputAction.newline, decoration: InputDecoration(hintText: isReplying ? 'اكتب ردك...' : 'اكتب تعليقاً...', filled: true, fillColor: colors.surfaceContainerHighest.withOpacity(.45), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: colors.primary, width: 1.2)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)))),
        const SizedBox(width: 8),
        ValueListenableBuilder<TextEditingValue>(valueListenable: _commentController, builder: (context, value, _) {
          final hasText = value.text.trim().isNotEmpty;
          return IconButton.filled(onPressed: hasText ? () => _sendComment(context) : null, icon: const Icon(Icons.send_rounded, size: 20), style: IconButton.styleFrom(backgroundColor: colors.primary, foregroundColor: colors.onPrimary, disabledBackgroundColor: colors.surfaceContainerHighest, disabledForegroundColor: colors.onSurfaceVariant, minimumSize: const Size(48, 48)));
        }),
      ]),
    ]))));
  }

  Future<void> _confirmDeleteComment(BuildContext context, int postId, int commentId) async {
    final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) {
      return Directionality(textDirection: TextDirection.rtl, child: AlertDialog(
        title: const Text('حذف التعليق'),
        content: const Text('هل أنت متأكد من أنك تريد حذف هذا التعليق؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text('حذف', style: TextStyle(color: Theme.of(dialogContext).colorScheme.error))),
        ],
      ));
    });
    if (!mounted || confirmed != true) return;
    _hasChanges = true;
    context.read<PostDetailsBloc>().add(DeleteCommentRequested(postId: postId, commentId: commentId));
  }
}

class _ReactionButton extends StatelessWidget {
  final String emoji;
  final String label;
  final int count;
  final VoidCallback onTap;
  const _ReactionButton({required this.emoji, required this.label, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(22), child: Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7), decoration: BoxDecoration(color: colors.surfaceContainerHighest.withOpacity(.5), borderRadius: BorderRadius.circular(22), border: Border.all(color: colors.outlineVariant.withOpacity(.35))), child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(emoji, style: const TextStyle(fontSize: 16)),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.onSurfaceVariant)),
      if (count > 0) ...[const SizedBox(width: 5), Text('$count', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: colors.onSurface))],
    ]))));
  }
}

class _CommentTile extends StatelessWidget {
  final CommentEntity comment;
  final VoidCallback onReply;
  final VoidCallback onDelete;
  final VoidCallback onLike;
  final VoidCallback onUnlike;
  const _CommentTile({required this.comment, required this.onReply, required this.onDelete, required this.onLike, required this.onUnlike});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasPicture = comment.author.picture != null && comment.author.picture!.trim().isNotEmpty;
    final isReply = comment.isReply;

    return Padding(
      padding: EdgeInsets.only(bottom: 12, right: isReply ? 36 : 0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(radius: 17, backgroundColor: AppColors.primaryLight, backgroundImage: hasPicture ? NetworkImage(comment.author.picture!) : null, child: !hasPicture ? Icon(Icons.person_rounded, size: 17, color: colors.primary) : null),
        const SizedBox(width: 9),
        Expanded(child: Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: colors.surfaceContainerHighest.withOpacity(.45), borderRadius: BorderRadius.circular(15)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(comment.author.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: colors.onSurface)),
          const SizedBox(height: 5),
          Text(comment.content, style: TextStyle(fontSize: 14, height: 1.5, color: colors.onSurface)),
          const SizedBox(height: 9),
          Row(children: [
            GestureDetector(onTap: onReply, child: Text('رد', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colors.primary))),
            const SizedBox(width: 18),
            GestureDetector(onTap: onLike, child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.favorite_border_rounded, size: 15, color: colors.onSurfaceVariant),
              if (comment.likeCount > 0) ...[const SizedBox(width: 4), Text('${comment.likeCount}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.onSurfaceVariant))],
            ])),
            const Spacer(),
            GestureDetector(onTap: onDelete, child: Icon(Icons.delete_outline_rounded, size: 16, color: colors.onSurfaceVariant)),
          ]),
        ]))),
      ]),
    );
  }
}