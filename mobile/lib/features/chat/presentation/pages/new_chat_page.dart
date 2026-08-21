import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/injection_container.dart';
import '../../../../core/utils/api_error_resolver.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/resilient_network_avatar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../friends/domain/entities/friend_user_entity.dart';
import '../../domain/usecases/create_direct_conversation_usecase.dart';
import '../bloc/chat_messages_bloc.dart';
import '../bloc/chat_messages_event.dart';
import '../bloc/new_chat_bloc.dart';
import '../bloc/new_chat_event.dart';
import '../bloc/new_chat_state.dart';
import 'chat_room_page.dart';

class NewChatPage extends StatelessWidget {
  const NewChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('محادثة جديدة'), centerTitle: true),
        body: BlocBuilder<NewChatBloc, NewChatState>(
          builder: (context, state) {
            if (state is NewChatInitial) {
              context.read<NewChatBloc>().add(LoadNewChatFriendsEvent());
              return const Center(child: CircularProgressIndicator());
            }

            if (state is NewChatLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is NewChatError) {
              return _NewChatErrorView(
                message: state.message,
                onRetry: () {
                  context.read<NewChatBloc>().add(LoadNewChatFriendsEvent());
                },
              );
            }

            if (state is NewChatLoaded) {
              final friends = state.friends;
              if (friends.isEmpty) {
                return const _EmptyFriendsView();
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<NewChatBloc>().add(LoadNewChatFriendsEvent());
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 30),
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    return _FriendPickTile(
                      user: friend,
                      onTap: () => _openConversation(context, friend),
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

  Future<void> _openConversation(
    BuildContext context,
    FriendUserEntity user,
  ) async {
    final currentUserId = _currentUserId(context);
    try {
      final conversation = await sl<CreateDirectConversationUseCase>().call(
        user.id,
      );
      if (!context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<ChatMessagesBloc>(
              param1: conversation.id,
              param2: currentUserId,
            )..add(OpenChatConversationEvent()),
            child: ChatRoomPage(
              conversationId: conversation.id,
              otherUser: user,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      AppToast.error(context, message: resolveApiErrorMessage(e));
    }
  }

  int _currentUserId(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    if (state is Authenticated) return state.authEntity.user.id;
    if (state is AuthSuccess) return state.authEntity.user.id;
    return 0;
  }
}

class _FriendPickTile extends StatelessWidget {
  final FriendUserEntity user;
  final VoidCallback onTap;

  const _FriendPickTile({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
                  radius: 24,
                  imageUrl: user.picture,
                  fallbackLabel: user.name,
                  backgroundColor: colors.primary.withValues(alpha: 0.1),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    user.name,
                    style: theme.textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Icon(
                  Icons.chevron_right_sharp,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NewChatErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _NewChatErrorView({required this.message, required this.onRetry});

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

class _EmptyFriendsView extends StatelessWidget {
  const _EmptyFriendsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 140),
        Icon(
          Icons.group_outlined,
          size: 64,
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 14),
        Text(
          'لا يوجد أصدقاء',
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'أضف أصدقاء ليتمكنوا من مراسلتك',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
