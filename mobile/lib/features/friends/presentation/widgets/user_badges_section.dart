import 'package:flutter/material.dart';

import '../../../../core/widgets/resilient_network_avatar.dart';
import '../../domain/entities/user_profile_entity.dart';

class UserBadgesSection extends StatelessWidget {
  final List<UserBadgeEntity> badges;

  const UserBadgesSection({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) return const SizedBox.shrink();

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