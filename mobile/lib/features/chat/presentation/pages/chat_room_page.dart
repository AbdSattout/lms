import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/resilient_network_avatar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../friends/domain/entities/friend_user_entity.dart';
import '../../../friends/presentation/bloc/user_profile_bloc.dart';
import '../../../friends/presentation/bloc/user_profile_event.dart';
import '../../../friends/presentation/pages/user_profile_page.dart';
import '../../domain/entities/message_entity.dart';
import '../bloc/chat_messages_bloc.dart';
import '../bloc/chat_messages_event.dart';
import '../bloc/chat_messages_state.dart';

class ChatRoomPage extends StatefulWidget {
  final int conversationId;
  final FriendUserEntity? otherUser;
  final String? title;
  final bool isCourseChat;

  const ChatRoomPage({
    super.key,
    required this.conversationId,
    this.otherUser,
    this.title,
    this.isCourseChat = false,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<ChatMessagesBloc>().add(LoadMoreMessagesEvent());
    }
  }

  void _handleSend(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    context.read<ChatMessagesBloc>().add(SendChatMessageEvent(trimmed));
    _textController.clear();
    _focusNode.requestFocus();
  }

  void _showMessageActions(BuildContext context, MessageEntity message) {
    final isMine = message.isMine(_currentUserId(context));
    if (!isMine) return;

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('تعديل الرسالة'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showEditMessageDialog(context, message);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'حذف الرسالة',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _confirmDeleteMessage(context, message);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditMessageDialog(
    BuildContext context,
    MessageEntity message,
  ) async {
    final controller = TextEditingController(text: message.content ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تعديل الرسالة'),
          content: TextField(
            controller: controller,
            autofocus: true,
            minLines: 2,
            maxLines: 5,
            decoration: const InputDecoration(hintText: 'اكتب رسالتك...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );

    final text = controller.text.trim();
    controller.dispose();
    if (saved != true || text.isEmpty) return;
    if (!context.mounted) return;

    context.read<ChatMessagesBloc>().add(
      EditChatMessageEvent(message.id, text),
    );
  }

  Future<void> _confirmDeleteMessage(
    BuildContext context,
    MessageEntity message,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف الرسالة'),
          content: const Text('هل أنت متأكد من أنك تريد حذف هذه الرسالة؟'),
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
    context.read<ChatMessagesBloc>().add(
      DeleteChatMessageEvent(message.id),
    );
  }

  int _currentUserId(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    if (state is Authenticated) return state.authEntity.user.id;
    if (state is AuthSuccess) return state.authEntity.user.id;
    return 0;
  }

  String _buildMutedMessage(DateTime? mutedUntil) {
    if (mutedUntil == null) return 'تم كتمك في هذه المحادثة';
    final target = mutedUntil.toLocal();
    final now = DateTime.now();
    final sameDay =
        target.year == now.year &&
        target.month == now.month &&
        target.day == now.day;
    final hh = target.hour.toString().padLeft(2, '0');
    final mm = target.minute.toString().padLeft(2, '0');
    if (sameDay) return 'تم كتمك في هذه المحادثة حتى الساعة $hh:$mm';
    final dd = target.day.toString().padLeft(2, '0');
    final mo = target.month.toString().padLeft(2, '0');
    return 'تم كتمك في هذه المحادثة حتى $dd/$mo/${target.year} $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _currentUserId(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title ?? widget.otherUser?.name ?? 'محادثة'),
          centerTitle: true,
          actions: [
            if (widget.otherUser != null)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Center(
                  child: ResilientNetworkAvatar(
                    radius: 18,
                    imageUrl: widget.otherUser?.picture,
                    fallbackLabel: widget.otherUser?.name,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
              ),
          ],
        ),
        body: BlocBuilder<ChatMessagesBloc, ChatMessagesState>(
          builder: (context, state) {
            if (state is ChatMessagesInitial || state is ChatMessagesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ChatMessagesError) {
              return _MessagesErrorView(
                message: state.message,
                onRetry: () {
                  context.read<ChatMessagesBloc>().add(
                    OpenChatConversationEvent(),
                  );
                },
              );
            }

            if (state is ChatMessagesLoaded) {
              return Column(
                children: [
                  Expanded(
                    child: _buildMessagesList(context, state, currentUserId),
                  ),
                  _Composer(
                    controller: _textController,
                    focusNode: _focusNode,
                    onSend: _handleSend,
                    isMuted: state.isMuted,
                    mutedMessage: _buildMutedMessage(state.mutedUntil),
                    muteReason: state.muteReason,
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildMessagesList(
    BuildContext context,
    ChatMessagesLoaded state,
    int currentUserId,
  ) {
    final items = <_ChatItem>[
      ...state.pendingMessages.entries.toList().reversed.map(
        (e) => _ChatItem.pending(e.key, e.value),
      ),
      ...state.failedMessages.entries.toList().reversed.map(
        (e) => _ChatItem.failed(e.key, e.value),
      ),
      ...state.messages.map((m) => _ChatItem.message(m)),
    ];

    if (items.isEmpty) {
      return const _EmptyMessagesView();
    }

    final isFirstInGroup = _computeGroupFirsts(items);
    final isLastInGroup = _computeGroupLasts(items);

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _MessageBubble(
          item: item,
          currentUserId: currentUserId,
          isCourseChat: widget.isCourseChat,
          isFirstInGroup: isFirstInGroup[index],
          isLastInGroup: isLastInGroup[index],
          onRetry: () {
            context.read<ChatMessagesBloc>().add(
              RetryChatMessageEvent(item.localId!),
            );
          },
          onEdit: (message) {
            _showEditMessageDialog(context, message);
          },
          onDelete: (message) {
            _confirmDeleteMessage(context, message);
          },
          onLongPress: (message) {
            _showMessageActions(context, message);
          },
        );
      },
    );
  }

  List<bool> _computeGroupFirsts(List<_ChatItem> items) {
    const groupGap = Duration(minutes: 5);
    final result = List<bool>.filled(items.length, false);

    for (var i = 0; i < items.length; i++) {
      if (i == items.length - 1) {
        result[i] = true;
        continue;
      }

      final current = items[i];
      final older = items[i + 1];
      final currentSenderId = current.message?.senderId;
      final olderSenderId = older.message?.senderId;

      if (currentSenderId == null || olderSenderId == null) {
        result[i] = true;
        continue;
      }

      if (currentSenderId != olderSenderId) {
        result[i] = true;
        continue;
      }

      final gap = older.message!.createdAt.difference(
        current.message!.createdAt,
      );
      result[i] = gap > groupGap;
    }

    return result;
  }

  List<bool> _computeGroupLasts(List<_ChatItem> items) {
    const groupGap = Duration(minutes: 5);
    final result = List<bool>.filled(items.length, false);

    for (var i = 0; i < items.length; i++) {
      if (i == 0) {
        result[i] = true;
        continue;
      }

      final current = items[i];
      final newer = items[i - 1];
      final currentSenderId = current.message?.senderId;
      final newerSenderId = newer.message?.senderId;

      if (currentSenderId == null || newerSenderId == null) {
        result[i] = true;
        continue;
      }

      if (currentSenderId != newerSenderId) {
        result[i] = true;
        continue;
      }

      final gap = current.message!.createdAt.difference(
        newer.message!.createdAt,
      );
      result[i] = gap > groupGap;
    }

    return result;
  }
}

class _ChatItem {
  final MessageEntity? message;
  final String? localId;
  final String? content;
  final bool isPending;
  final bool isFailed;

  const _ChatItem.message(this.message)
    : localId = null,
      content = null,
      isPending = false,
      isFailed = false;

  const _ChatItem.pending(this.localId, this.content)
    : message = null,
      isPending = true,
      isFailed = false;

  const _ChatItem.failed(this.localId, this.content)
    : message = null,
      isPending = false,
      isFailed = true;
}

class _MessageBubble extends StatelessWidget {
  final _ChatItem item;
  final int currentUserId;
  final bool isCourseChat;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final VoidCallback onRetry;
  final ValueChanged<MessageEntity> onEdit;
  final ValueChanged<MessageEntity> onDelete;
  final ValueChanged<MessageEntity> onLongPress;

  const _MessageBubble({
    required this.item,
    required this.currentUserId,
    required this.isCourseChat,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.onRetry,
    required this.onEdit,
    required this.onDelete,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isMine = item.message != null
        ? item.message!.isMine(currentUserId)
        : true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: _BubbleBody(
        item: item,
        isMine: isMine,
        currentUserId: currentUserId,
        isCourseChat: isCourseChat,
        isFirstInGroup: isFirstInGroup,
        isLastInGroup: isLastInGroup,
        onRetry: onRetry,
        onEdit: onEdit,
        onDelete: onDelete,
        onLongPress: onLongPress,
      ),
    );
  }
}

class _BubbleBody extends StatelessWidget {
  final _ChatItem item;
  final bool isMine;
  final int currentUserId;
  final bool isCourseChat;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final VoidCallback onRetry;
  final ValueChanged<MessageEntity> onEdit;
  final ValueChanged<MessageEntity> onDelete;
  final ValueChanged<MessageEntity> onLongPress;

  const _BubbleBody({
    required this.item,
    required this.isMine,
    required this.currentUserId,
    required this.isCourseChat,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.onRetry,
    required this.onEdit,
    required this.onDelete,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final isDark = theme.brightness == Brightness.dark;
    final bubbleColor = isMine
        ? AppColors.primary.withValues(alpha: isDark ? 0.28 : 0.14)
        : theme.cardColor;
    final textColor = isMine
        ? (isDark ? AppColors.primaryLight : colors.primary)
        : colors.onSurface;

    final showAvatar =
        !isMine && item.message != null && (!isCourseChat || isFirstInGroup);
    final showName = !isMine && isCourseChat && isFirstInGroup;
    final isDeleted = item.message?.isDeleted ?? false;
    final isFailed = item.isFailed;

    const bubbleRadius = Radius.circular(18);
    const flatRadius = Radius.circular(4);

    bool topSenderFlat;
    bool bottomSenderFlat;
    if (isFirstInGroup) {
      topSenderFlat = false;
      bottomSenderFlat = true;
    } else if (isLastInGroup) {
      topSenderFlat = true;
      bottomSenderFlat = false;
    } else {
      topSenderFlat = true;
      bottomSenderFlat = true;
    }

    final topLeft = (!isMine && topSenderFlat) ? flatRadius : bubbleRadius;
    final topRight = (isMine && topSenderFlat) ? flatRadius : bubbleRadius;
    final bottomLeft = (!isMine && bottomSenderFlat) ? flatRadius : bubbleRadius;
    final bottomRight = (isMine && bottomSenderFlat) ? flatRadius : bubbleRadius;

    final bubble = Material(
      color: bubbleColor,
      borderRadius: BorderRadius.only(
        topLeft: topLeft,
        topRight: topRight,
        bottomLeft: bottomLeft,
        bottomRight: bottomRight,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDeleted)
              Text(
                'تم حذف هذه الرسالة',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Text(
                item.content ?? item.message?.content ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isFailed)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 15,
                      color: colors.error,
                    ),
                  ),
                if (item.isPending)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 1.6),
                  ),
                if (item.isPending || isFailed) const SizedBox(width: 5),
                if (item.message?.editedAt != null) ...[
                  Text(
                    'معدلة',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  _formatTime(
                    item.message?.createdAt ?? DateTime.now().toLocal(),
                  ),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    const double avatarRadius = 15;
    const double avatarSlotWidth = avatarRadius * 2 + 8;

    final Widget interactive = isMine && !isDeleted
        ? GestureDetector(
            onLongPress: () => onLongPress(item.message!),
            child: bubble,
          )
        : bubble;

    if (isMine) {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: interactive,
      );
    }

    final Widget avatarSlot = showAvatar
        ? Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ResilientNetworkAvatar(
              radius: avatarRadius,
              imageUrl: item.message?.senderPicture,
              fallbackLabel: item.message?.senderName,
              backgroundColor: colors.primary.withValues(alpha: 0.1),
              onTap: item.message == null
                  ? null
                  : () => _openUserProfile(context, item.message!),
            ),
          )
        : const SizedBox(width: avatarSlotWidth);

    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Row(
        textDirection: TextDirection.ltr,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          avatarSlot,
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showName) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child: Text(
                      item.message?.senderName ?? '',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                interactive,
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSend;
  final bool isMuted;
  final String mutedMessage;
  final String? muteReason;

  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    this.isMuted = false,
    this.mutedMessage = 'تم كتمك في هذه المحادثة',
    this.muteReason,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (isMuted) {
      return Material(
        color: theme.scaffoldBackgroundColor,
        elevation: 8,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.block_rounded,
                  size: 22,
                  color: colors.error,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        mutedMessage,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      if (muteReason != null && muteReason!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          muteReason!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: theme.scaffoldBackgroundColor,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالتك...',
                    filled: true,
                    fillColor: theme.cardColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: onSend,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () => onSend(controller.text),
                icon: const Icon(Icons.send_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                ),
                padding: const EdgeInsets.all(10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessagesErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _MessagesErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMessagesView extends StatelessWidget {
  const _EmptyMessagesView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 64,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 14),
          Text('ابدأ المحادثة', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'أرسل أول رسالة الآن',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

void _openUserProfile(BuildContext context, MessageEntity message) {
  if (message.senderId <= 0) return;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) =>
            sl<UserProfileBloc>()..add(LoadUserProfileEvent(message.senderId)),
        child: UserProfilePage(
          userId: message.senderId,
          initialUser: FriendUserEntity(
            id: message.senderId,
            name: message.senderName,
            picture: message.senderPicture,
          ),
        ),
      ),
    ),
  );
}
