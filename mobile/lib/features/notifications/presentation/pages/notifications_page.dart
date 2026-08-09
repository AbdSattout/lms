import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/injection_container.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/resilient_network_avatar.dart';
import '../../../organizations/domain/entities/organization_invite_entity.dart';
import '../../../organizations/presentation/bloc/organization_details_bloc.dart';
import '../../../organizations/presentation/bloc/organization_details_event.dart';
import '../../../organizations/presentation/pages/organization_details_page.dart';
import '../../domain/entities/app_notification_entity.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإشعارات'),
          actions: [
            BlocBuilder<NotificationsBloc, NotificationsState>(
              builder: (context, state) {
                final canMarkAllRead =
                    state is NotificationsLoaded && state.unreadCount > 0;

                return IconButton(
                  onPressed: canMarkAllRead
                      ? () {
                          context.read<NotificationsBloc>().add(
                            MarkAllNotificationsReadEvent(),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.done_all_rounded),
                  tooltip: 'تعليم الكل كمقروء',
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<NotificationsBloc, NotificationsState>(
          listenWhen: (previous, current) {
            if (current is! NotificationsLoaded) return false;
            if (current.actionMessage != null) return true;
            if (current.errorMessage != null) return true;
            return false;
          },
          listener: (context, state) {
            if (state is! NotificationsLoaded) return;

            final messenger = ScaffoldMessenger.of(context);
            final message = state.actionMessage ?? state.errorMessage;
            if (message == null) return;

            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
          },
          builder: (context, state) {
            if (state is NotificationsInitial) {
              context.read<NotificationsBloc>().add(LoadNotificationsEvent());
              return const _LoadingView();
            }

            if (state is NotificationsLoading) {
              return const _LoadingView();
            }

            if (state is NotificationsError) {
              return _ErrorView(
                message: state.message,
                onRetry: () {
                  context.read<NotificationsBloc>().add(
                    LoadNotificationsEvent(),
                  );
                },
              );
            }

            if (state is NotificationsLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<NotificationsBloc>().add(
                    RefreshNotificationsEvent(),
                  );
                },
                child: _NotificationsList(state: state),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _NotificationsList extends StatelessWidget {
  final NotificationsLoaded state;

  const _NotificationsList({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.invites.isEmpty && state.notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [SizedBox(height: 120), _EmptyView()],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 110),
      children: [
        if (state.invites.isNotEmpty) ...[
          _SectionTitle(title: 'دعوات المنظمات', count: state.invites.length),
          const SizedBox(height: 10),
          ...state.invites.map(
            (invite) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _InviteCard(
                invite: invite,
                isProcessing: state.processingInviteId == invite.id,
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (state.notifications.isNotEmpty) ...[
          _SectionTitle(
            title: 'آخر الإشعارات',
            count: state.notifications.length,
          ),
          const SizedBox(height: 10),
          ...state.notifications.map(
            (notification) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _NotificationTile(notification: notification),
            ),
          ),
        ],
      ],
    );
  }
}

class _InviteCard extends StatelessWidget {
  final OrganizationInviteEntity invite;
  final bool isProcessing;

  const _InviteCard({required this.invite, required this.isProcessing});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final overview = invite.overview;

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isProcessing
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => sl<OrganizationDetailsBloc>()
                        ..add(
                          GetOrganizationDetailsEvent(invite.organization.slug),
                        ),
                      child: OrganizationDetailsPage(
                        slug: invite.organization.slug,
                      ),
                    ),
                  ),
                ).then((_) {
                  if (!context.mounted) return;
                  context.read<NotificationsBloc>().add(
                    RefreshNotificationsEvent(),
                  );
                });
              },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResilientNetworkAvatar(
                    radius: 25,
                    imageUrl: invite.organization.imageUrl,
                    fallbackLabel: invite.organization.name,
                    backgroundColor: colors.surfaceContainerHighest,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invite.organization.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'دعاك ${invite.invitedByName ?? 'أحد مسؤولي المنظمة'} للانضمام كطالب.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (invite.organization.description != null &&
                  invite.organization.description!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  invite.organization.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (overview != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoPill(
                      icon: Icons.people_alt_rounded,
                      label: '${overview.membersCount} أعضاء',
                    ),
                    _InfoPill(
                      icon: Icons.menu_book_rounded,
                      label: '${overview.publishedCoursesCount} كورسات',
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isProcessing
                          ? null
                          : () {
                              context.read<NotificationsBloc>().add(
                                AcceptOrganizationInviteEvent(invite),
                              );
                            },
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
                      onPressed: isProcessing
                          ? null
                          : () {
                              context.read<NotificationsBloc>().add(
                                DeclineOrganizationInviteEvent(invite),
                              );
                            },
                      icon: const Icon(Icons.close_rounded, size: 19),
                      label: const Text('رفض'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotificationEntity notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = notification.read ? colors.outline : colors.primary;

    return Material(
      color: notification.read
          ? Theme.of(context).cardColor
          : colors.primaryContainer.withValues(alpha: 0.22),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          context.read<NotificationsBloc>().add(
            MarkNotificationReadEvent(notification),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: notification.read
                  ? colors.outlineVariant
                  : colors.primary.withValues(alpha: 0.30),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_iconForType(notification.type), color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        if (!notification.read) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (notification.createdAt != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        formatArabicRelativeTime(notification.createdAt!),
                        style: Theme.of(context).textTheme.labelSmall,
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

  IconData _iconForType(String type) {
    return switch (type) {
      'ORGANIZATION_INVITE' => Icons.groups_rounded,
      'ORGANIZATION_JOIN_REQUEST' => Icons.person_add_alt_rounded,
      'ORGANIZATION_JOIN_REQUEST_ACCEPTED' => Icons.verified_user_rounded,
      'COURSE_PUBLISHED' => Icons.menu_book_rounded,
      'FRIEND_REQUEST' => Icons.person_add_rounded,
      'FRIEND_REQUEST_ACCEPTED' => Icons.how_to_reg_rounded,
      _ => Icons.notifications_rounded,
    };
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: colors.primary),
          const SizedBox(width: 5),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final int count;

  const _SectionTitle({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(width: 8),
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off_rounded,
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

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 50,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد دعوات أو إشعارات حالياً',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
