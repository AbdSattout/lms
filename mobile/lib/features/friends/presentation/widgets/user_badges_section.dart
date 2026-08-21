import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/resilient_network_avatar.dart';
import '../../domain/entities/user_profile_entity.dart';

class UserBadgesSection extends StatelessWidget {
  final List<UserBadgeEntity> badges;

  const UserBadgesSection({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.secondaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                size: 18,
                color: colors.secondary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'الشارات',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 88,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? colors.surfaceContainerLow
              : colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? colors.outlineVariant.withValues(alpha: 0.4)
                : colors.outlineVariant.withValues(alpha: 0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            if (badge.iconUrl != null)
              ResilientNetworkAvatar(
                radius: 26,
                imageUrl: badge.iconUrl,
                fallbackLabel: badge.title,
                backgroundColor: colors.secondaryContainer,
              )
            else
              CircleAvatar(
                radius: 26,
                backgroundColor: colors.secondaryContainer.withValues(alpha: 0.5),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: colors.secondary,
                  size: 26,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              badge.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}