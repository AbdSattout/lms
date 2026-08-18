import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/resilient_network_avatar.dart';
import '../../../reports/domain/entities/report_target.dart';
import '../../../reports/presentation/widgets/report_bottom_sheet.dart';
import '../../domain/entities/friend_user_entity.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../bloc/user_profile_bloc.dart';
import '../bloc/user_profile_event.dart';
import '../bloc/user_profile_state.dart';

class UserProfilePage extends StatefulWidget {
  final int userId;
  final FriendUserEntity? initialUser;
  final int? friendshipId;

  const UserProfilePage({
    super.key,
    required this.userId,
    this.initialUser,
    this.friendshipId,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _removing = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('الملف الشخصي'),
          centerTitle: true,
          actions: [
            _UserReportAction(
              userId: widget.userId,
              initialName: widget.initialUser?.name,
            ),
          ],
        ),
        body: BlocConsumer<UserProfileBloc, UserProfileState>(
          listenWhen: (previous, current) {
            if (_removing) return true;
            if (current is! UserProfileLoaded) return false;
            if (current.actionMessage != null) return true;
            if (current.errorMessage != null) return true;
            return false;
          },
          listener: (context, state) {
            if (state is! UserProfileLoaded) return;

            if (_removing && state.profile.friendship.status != 'FRIENDS') {
              _removing = false;
              Navigator.of(context).pop(true);
              return;
            }

            final messenger = ScaffoldMessenger.of(context);
            final message = state.actionMessage ?? state.errorMessage;
            if (message == null) return;

            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
          },
          builder: (context, state) {
            if (state is UserProfileLoading) {
              return _buildLoading(context);
            }

            if (state is UserProfileError) {
              return _ErrorView(
                message: state.message,
                onRetry: () {
                  context.read<UserProfileBloc>().add(
                    LoadUserProfileEvent(widget.userId),
                  );
                },
              );
            }

            if (state is UserProfileLoaded) {
              return _buildLoaded(context, state);
            }

            return _buildLoading(context);
          },
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    final initialUser = widget.initialUser;
    if (initialUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          _HeaderCard(
            name: initialUser.name,
            username: initialUser.username,
            picture: initialUser.picture,
          ),
          const SizedBox(height: 24),
          const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, UserProfileLoaded state) {
    final profile = state.profile;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeaderCard(
            name: profile.profile.name,
            username: profile.profile.user.username,
            picture: profile.profile.user.picture,
            email: profile.profile.email,
          ),
          const SizedBox(height: 20),
          _FriendshipActionArea(
            profile: profile,
            friendshipId: widget.friendshipId,
            processingId: state.processingId,
            onSendRequest: () {
              context.read<UserProfileBloc>().add(
                SendFriendRequestEvent(widget.userId),
              );
            },
            onAcceptRequest: (requestId) {
              context.read<UserProfileBloc>().add(
                AcceptFriendRequestEvent(requestId),
              );
            },
            onRejectRequest: (requestId) {
              context.read<UserProfileBloc>().add(
                RejectFriendRequestEvent(requestId),
              );
            },
            onCancelRequest: (requestId) {
              context.read<UserProfileBloc>().add(
                CancelFriendRequestEvent(requestId),
              );
            },
            onRemoveFriend: () => _confirmRemove(),
          ),
          const SizedBox(height: 20),
          _StatsCard(profile: profile),
          if (profile.badges.isNotEmpty) ...[
            const SizedBox(height: 20),
            _BadgesSection(badges: profile.badges),
          ],
          if (profile.recentCourses.isNotEmpty) ...[
            const SizedBox(height: 20),
            _RecentCoursesSection(courses: profile.recentCourses),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmRemove() async {
    final friendshipId = widget.friendshipId;
    if (friendshipId == null) return;

    final bloc = context.read<UserProfileBloc>();
    final currentState = bloc.state;
    final name = currentState is UserProfileLoaded
        ? currentState.profile.profile.name
        : (widget.initialUser?.name ?? '');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إزالة الصديق'),
        content: Text('هل أنت متأكد من إزالة $name من قائمة أصدقائك؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('إزالة'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _removing = true);
    bloc.add(RemoveFriendEvent(friendshipId));
  }
}

class _UserReportAction extends StatelessWidget {
  final int userId;
  final String? initialName;

  const _UserReportAction({required this.userId, this.initialName});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileBloc, UserProfileState>(
      builder: (context, state) {
        if (state is UserProfileLoaded &&
            state.profile.friendship.status == 'SELF') {
          return const SizedBox.shrink();
        }

        final loadedName = state is UserProfileLoaded
            ? state.profile.profile.name
            : null;
        final name = loadedName?.trim().isNotEmpty == true
            ? loadedName!
            : (initialName?.trim().isNotEmpty == true
                  ? initialName!
                  : 'المستخدم');

        return IconButton(
          tooltip: 'إبلاغ',
          icon: const Icon(Icons.outlined_flag_rounded),
          onPressed: () {
            showReportBottomSheet(
              context,
              ReportTarget.user(userId: userId, title: name),
            );
          },
        );
      },
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String name;
  final String? username;
  final String? picture;
  final String? email;
  final String? university;
  final String? phone;

  const _HeaderCard({
    required this.name,
    this.username,
    this.picture,
    this.email,
    this.university,
    this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 158,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      AppColors.primary,
                      isDark
                          ? AppColors.primary.withValues(alpha: 0.44)
                          : AppColors.primaryLight,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: _ProfileAvatar(name: name, picture: picture),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        if (username != null && username!.trim().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            '@$username',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (email != null && email!.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mail_outline_rounded,
                size: 15,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  email!,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String name;
  final String? picture;

  const _ProfileAvatar({required this.name, required this.picture});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: ResilientNetworkAvatar(
        radius: 48,
        imageUrl: picture,
        fallbackLabel: name,
        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
    );
  }
}

class _FriendshipActionArea extends StatelessWidget {
  final UserProfileEntity profile;
  final int? friendshipId;
  final int? processingId;
  final VoidCallback onSendRequest;
  final void Function(int requestId) onAcceptRequest;
  final void Function(int requestId) onRejectRequest;
  final void Function(int requestId) onCancelRequest;
  final VoidCallback onRemoveFriend;

  const _FriendshipActionArea({
    required this.profile,
    this.friendshipId,
    this.processingId,
    required this.onSendRequest,
    required this.onAcceptRequest,
    required this.onRejectRequest,
    required this.onCancelRequest,
    required this.onRemoveFriend,
  });

  @override
  Widget build(BuildContext context) {
    final friendship = profile.friendship;
    final userId = profile.profile.user.id;

    switch (friendship.status) {
      case 'SELF':
        return _SelfChip();
      case 'FRIENDS':
        if (friendshipId == null) {
          return _FriendsChip();
        }
        return _RemoveFriendButton(
          isProcessing: processingId == friendshipId,
          onPressed: onRemoveFriend,
        );
      case 'REQUEST_SENT':
        final requestId = friendship.pendingRequestId;
        return OutlinedButton.icon(
          onPressed: requestId == null
              ? null
              : (processingId == requestId
                    ? null
                    : () => onCancelRequest(requestId)),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: processingId == requestId
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.close_rounded, size: 20),
          label: const Text(
            'إلغاء الطلب',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        );
      case 'REQUEST_RECEIVED':
        final requestId = friendship.pendingRequestId;
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: requestId == null
                    ? null
                    : (processingId == requestId
                          ? null
                          : () => onAcceptRequest(requestId)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: processingId == requestId
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded, size: 20),
                label: const Text(
                  'قبول',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: requestId == null
                    ? null
                    : (processingId == requestId
                          ? null
                          : () => onRejectRequest(requestId)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.close_rounded, size: 20),
                label: const Text(
                  'رفض',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        );
      case 'NONE':
      default:
        return ElevatedButton.icon(
          onPressed: !friendship.canSendFriendRequest
              ? null
              : (processingId == userId ? null : onSendRequest),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: processingId == userId
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.person_add_alt_rounded, size: 20),
          label: const Text(
            'إضافة كصديق',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        );
    }
  }
}

class _SelfChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_rounded, size: 20, color: colors.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            'هذا أنت',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendsChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.how_to_reg_rounded, size: 20, color: colors.primary),
          const SizedBox(width: 8),
          Text(
            'أصدقاء',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RemoveFriendButton extends StatelessWidget {
  final bool isProcessing;
  final VoidCallback onPressed;

  const _RemoveFriendButton({
    required this.isProcessing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isProcessing ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: BorderSide(color: Colors.red.withValues(alpha: 0.4)),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: isProcessing
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.person_remove_rounded, size: 20),
      label: Text(
        isProcessing ? 'جارٍ الإزالة...' : 'إزالة الصديق',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final UserProfileEntity profile;

  const _StatsCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final stats = profile.stats;
    final gamification = profile.gamification;

    final items = <_StatItem>[
      _StatItem(value: stats.friendsCount, label: 'الأصدقاء'),
      _StatItem(value: stats.enrolledCoursesCount, label: 'الدورات'),
      _StatItem(value: stats.certificatesCount, label: 'الشهادات'),
      if (gamification.totalXp != null)
        _StatItem(value: gamification.totalXp!, label: 'نقاط الخبرة'),
      if (gamification.levelNumber != null)
        _StatItem(value: gamification.levelNumber!, label: 'المستوى'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final item in items)
            SizedBox(
              width: (MediaQuery.of(context).size.width - 40 - 28 - 24) / 3,
              child: _StatCell(item: item),
            ),
        ],
      ),
    );
  }
}

class _StatItem {
  final int value;
  final String label;

  const _StatItem({required this.value, required this.label});
}

class _StatCell extends StatelessWidget {
  final _StatItem item;

  const _StatCell({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          '${item.value}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: colors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          item.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _BadgesSection extends StatelessWidget {
  final List<UserBadgeEntity> badges;

  const _BadgesSection({required this.badges});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الشارات',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: badges.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final badge = badges[index];
              return _BadgeTile(badge: badge);
            },
          ),
        ),
      ],
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final UserBadgeEntity badge;

  const _BadgeTile({required this.badge});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: 84,
      child: Column(
        children: [
          if (badge.iconUrl != null)
            ResilientNetworkAvatar(
              radius: 26,
              imageUrl: badge.iconUrl,
              fallbackLabel: badge.title,
              backgroundColor: colors.surfaceContainerHighest,
            )
          else
            CircleAvatar(
              radius: 26,
              backgroundColor: colors.surfaceContainerHighest,
              child: Icon(
                Icons.emoji_events_rounded,
                color: colors.primary,
                size: 26,
              ),
            ),
          const SizedBox(height: 6),
          Text(
            badge.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _RecentCoursesSection extends StatelessWidget {
  final List<UserRecentCourseEntity> courses;

  const _RecentCoursesSection({required this.courses});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الدورات الحديثة',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        for (final course in courses)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _RecentCourseTile(course: course),
          ),
      ],
    );
  }
}

class _RecentCourseTile extends StatelessWidget {
  final UserRecentCourseEntity course;

  const _RecentCourseTile({required this.course});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 46,
              height: 46,
              child: course.coverUrl != null
                  ? Image.network(
                      course.coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _CourseThumbPlaceholder(),
                    )
                  : _CourseThumbPlaceholder(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (course.organizationName != null &&
                    course.organizationName!.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    course.organizationName!,
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
        ],
      ),
    );
  }
}

class _CourseThumbPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.menu_book_rounded,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
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
              Icons.person_off_outlined,
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
