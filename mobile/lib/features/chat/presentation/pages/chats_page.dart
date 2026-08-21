import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/injection_container.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/resilient_network_avatar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../friends/domain/entities/friend_user_entity.dart';
import '../../domain/entities/conversation_entity.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_messages_bloc.dart';
import '../bloc/chat_messages_event.dart';
import '../bloc/chat_state.dart';
import '../bloc/new_chat_bloc.dart';
import '../bloc/new_chat_event.dart';
import 'chat_room_page.dart';
import 'new_chat_page.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<ChatBloc>().add(LoadMoreChatsEvent());
    }
  }

  int _currentUserId(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    if (state is Authenticated) return state.authEntity.user.id;
    if (state is AuthSuccess) return state.authEntity.user.id;
    return 0;
  }

  void _openNewChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<NewChatBloc>()..add(LoadNewChatFriendsEvent()),
          child: const NewChatPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _currentUserId(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الرسائل'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              tooltip: 'محادثة جديدة',
              onPressed: _openNewChat,
            ),
          ],
        ),
        body: BlocConsumer<ChatBloc, ChatsState>(
          listenWhen: (previous, current) {
            if (current is! ChatsLoaded) return false;
            if (current.actionMessage != null) return true;
            if (current.errorMessage != null) return true;
            return false;
          },
          listener: (context, state) {
            if (state is! ChatsLoaded) return;
            final messenger = ScaffoldMessenger.of(context);
            final message = state.actionMessage ?? state.errorMessage;
            if (message == null) return;
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
          },
          builder: (context, state) {
            if (state is ChatsInitial) {
              context.read<ChatBloc>().add(LoadChatsEvent());
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ChatsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ChatsError) {
              return _ChatsErrorView(
                message: state.message,
                onRetry: () {
                  context.read<ChatBloc>().add(LoadChatsEvent());
                },
              );
            }

            if (state is ChatsLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ChatBloc>().add(RefreshChatsEvent());
                },
                child: state.conversations.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 140),
                          _EmptyChatsView(),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 30),
                        itemCount: state.conversations.length + 1,
                        itemBuilder: (context, index) {
                          if (index == state.conversations.length) {
                            if (state.isLoadingMore) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }

                          final conversation = state.conversations[index];
                          final otherUser = conversation.otherUser(currentUserId);

                          return _ConversationTile(
                            conversation: conversation,
                            otherUser: otherUser,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => _buildRoomRoute(
                                    conversation,
                                    otherUser,
                                    currentUserId,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildRoomRoute(
    ConversationEntity conversation,
    FriendUserEntity? otherUser,
    int currentUserId,
  ) {
    return BlocProvider(
      create: (_) =>
          sl<ChatMessagesBloc>(param1: conversation.id, param2: currentUserId)
            ..add(OpenChatConversationEvent()),
      child: ChatRoomPage(
        conversationId: conversation.id,
        otherUser: otherUser,
        isCourseChat: conversation.type == ConversationType.course,
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationEntity conversation;
  final FriendUserEntity? otherUser;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.otherUser,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final title =
        otherUser?.name ??
        (conversation.type == ConversationType.course
            ? 'محادثة الدورة'
            : 'محادثة');
    final preview = conversation.lastMessagePreview ?? '';
    final time = conversation.lastMessageAt;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                ResilientNetworkAvatar(
                  radius: 26,
                  imageUrl: otherUser?.picture,
                  fallbackLabel: otherUser?.name,
                  backgroundColor: colors.primary.withValues(alpha: 0.1),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: theme.textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          if (time != null)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                start: 8,
                              ),
                              child: Text(
                                formatArabicRelativeTime(time),
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        preview,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatsErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ChatsErrorView({required this.message, required this.onRetry});

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

class _EmptyChatsView extends StatelessWidget {
  const _EmptyChatsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(
          Icons.chat_bubble_outline_rounded,
          size: 64,
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 14),
        Text(
          'لا توجد محادثات بعد',
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'اضغط على أيقونة التحرير لبدء محادثة مع صديق',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
