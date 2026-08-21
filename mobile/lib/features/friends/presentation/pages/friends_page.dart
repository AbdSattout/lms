import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/injection_container.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/resilient_network_avatar.dart';
import '../../domain/entities/friend_entity.dart';
import '../../domain/entities/friend_user_entity.dart';
import '../bloc/friends_bloc.dart';
import '../bloc/friends_event.dart';
import '../bloc/friends_state.dart';
import '../bloc/user_profile_bloc.dart';
import '../bloc/user_profile_event.dart' show LoadUserProfileEvent;
import 'add_friend_page.dart';
import 'user_profile_page.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('الأصدقاء'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add_alt_rounded),
                tooltip: 'إضافة صديق',
                onPressed: () => _openAddFriend(context),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: BlocBuilder<FriendsBloc, FriendsState>(
                builder: (context, state) {
                  final friendsCount =
                      state is FriendsLoaded ? state.friends.length : 0;
                  final receivedCount = state is FriendsLoaded
                      ? state.receivedRequests.length
                      : 0;
                  final sentCount = state is FriendsLoaded
                      ? state.sentRequests.length
                      : 0;

                  return TabBar(
                    dividerColor: Colors.transparent,
                    dividerHeight: 0,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    indicatorWeight: 3,
                    tabs: [
                      Tab(
                        child: _BadgeTab(
                          label: 'الأصدقاء',
                          count: friendsCount,
                        ),
                      ),
                      Tab(
                        child: _BadgeTab(
                          label: 'الطلبات',
                          count: receivedCount,
                        ),
                      ),
                      Tab(
                        child: _BadgeTab(
                          label: 'المرسلة',
                          count: sentCount,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          body: BlocConsumer<FriendsBloc, FriendsState>(
            listenWhen: (previous, current) {
              if (current is! FriendsLoaded) return false;
              if (current.actionMessage != null) return true;
              if (current.errorMessage != null) return true;
              return false;
            },
            listener: (context, state) {
              if (state is! FriendsLoaded) return;

              final message = state.actionMessage ?? state.errorMessage;
              if (message == null) return;

              AppToast.error(context, message: message);
            },
            builder: (context, state) {
              if (state is FriendsInitial) {
                context.read<FriendsBloc>().add(LoadFriendsEvent());
                return const Center(child: CircularProgressIndicator());
              }

              if (state is FriendsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is FriendsError) {
                return _FriendsErrorView(
                  message: state.message,
                  onRetry: () {
                    context.read<FriendsBloc>().add(LoadFriendsEvent());
                  },
                );
              }

              if (state is FriendsLoaded) {
                return TabBarView(
                  children: [
                    _FriendsTab(state: state),
                    _ReceivedRequestsTab(state: state),
                    _SentRequestsTab(state: state),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  void _openAddFriend(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddFriendPage()),
    ).then((_) {
      if (!context.mounted) return;
      context.read<FriendsBloc>().add(RefreshFriendsEvent());
    });
  }
}

void _openProfile(
  BuildContext context,
  FriendUserEntity user, {
  int? friendshipId,
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) =>
            sl<UserProfileBloc>()..add(LoadUserProfileEvent(user.id)),
        child: UserProfilePage(
          userId: user.id,
          initialUser: user,
          friendshipId: friendshipId,
        ),
      ),
    ),
  ).then((removed) {
    if (!context.mounted) return;
    if (removed == true) {
      context.read<FriendsBloc>().add(RefreshFriendsEvent());
    }
  });
}

class _FriendsTab extends StatelessWidget {
  final FriendsLoaded state;

  const _FriendsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final friends = state.friends;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<FriendsBloc>().add(RefreshFriendsEvent());
      },
      child: friends.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 140),
                _EmptyView(
                  icon: Icons.people_outline_rounded,
                  message:
                      'لا يوجد أصدقاء بعد، اضغط على أيقونة الإضافة لإيجاد أصدقاء جدد',
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 40),
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _FriendTile(
                    friend: friend,
                    isProcessing: state.processingId == friend.id,
                    onTap: () => _openProfile(
                      context,
                      friend.user,
                      friendshipId: friend.id,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _ReceivedRequestsTab extends StatelessWidget {
  final FriendsLoaded state;

  const _ReceivedRequestsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final requests = state.receivedRequests;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<FriendsBloc>().add(RefreshFriendsEvent());
      },
      child: requests.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 140),
                _EmptyView(
                  icon: Icons.mark_email_unread_outlined,
                  message: 'لا توجد طلبات صداقة واردة حالياً',
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 40),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RequestTile(
                    user: request.sender,
                    createdAt: request.createdAt,
                    isProcessing: state.processingId == request.id,
                    onTap: () => _openProfile(context, request.sender),
                    onAccept: () {
                      context.read<FriendsBloc>().add(
                        AcceptFriendRequestEvent(request),
                      );
                    },
                    onReject: () {
                      context.read<FriendsBloc>().add(
                        RejectFriendRequestEvent(request),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _SentRequestsTab extends StatelessWidget {
  final FriendsLoaded state;

  const _SentRequestsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final requests = state.sentRequests;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<FriendsBloc>().add(RefreshFriendsEvent());
      },
      child: requests.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 140),
                _EmptyView(
                  icon: Icons.outbox_rounded,
                  message: 'لا توجد طلبات صداقة مرسلة',
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 40),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RequestTile(
                    user: request.receiver,
                    createdAt: request.createdAt,
                    isProcessing: state.processingId == request.id,
                    onTap: () => _openProfile(context, request.receiver),
                    onCancel: () {
                      context.read<FriendsBloc>().add(
                        CancelFriendRequestEvent(request),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  final FriendEntity friend;
  final bool isProcessing;
  final VoidCallback onTap;

  const _FriendTile({
    required this.friend,
    required this.isProcessing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final user = friend.user;

    return Material(
      color: Theme.of(context).cardColor,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (user.username != null &&
                        user.username!.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '@${user.username}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isProcessing)
                const Padding(
                  padding: EdgeInsets.all(6),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                Icon(
                  Icons.chevron_left_rounded,
                  color: colors.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  final FriendUserEntity user;
  final DateTime? createdAt;
  final bool isProcessing;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onCancel;

  const _RequestTile({
    required this.user,
    this.createdAt,
    required this.isProcessing,
    this.onTap,
    this.onAccept,
    this.onReject,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final name = user.name;
    final picture = user.picture;
    final username = user.username;
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ResilientNetworkAvatar(
                    radius: 24,
                    imageUrl: picture,
                    fallbackLabel: name,
                    backgroundColor: colors.primary.withValues(alpha: 0.1),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        if (username != null && username.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            '@$username',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (createdAt != null)
                    Text(
                      formatArabicRelativeTime(createdAt!),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (onAccept != null && onReject != null)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isProcessing ? null : onAccept,
                        icon: isProcessing
                            ? const SizedBox(
                                width: 17,
                                height: 17,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.check_rounded, size: 19),
                        label: const Text('قبول'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isProcessing ? null : onReject,
                        icon: const Icon(Icons.close_rounded, size: 19),
                        label: const Text('رفض'),
                      ),
                    ),
                  ],
                )
              else if (onCancel != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isProcessing ? null : onCancel,
                    icon: isProcessing
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.close_rounded, size: 19),
                    label: const Text('إلغاء الطلب'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyView({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            Icon(
              icon,
              size: 50,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendsErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _FriendsErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 44,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeTab extends StatelessWidget {
  final String label;
  final int count;

  const _BadgeTab({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        if (count > 0) ...[
          const SizedBox(width: 6),
          _CountBadge(count: count),
        ],
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 18,
        constraints: const BoxConstraints(minWidth: 18),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          count > 99 ? '99+' : '$count',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
