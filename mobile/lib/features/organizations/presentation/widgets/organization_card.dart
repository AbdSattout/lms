import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/organization_entity.dart';

class OrganizationCard extends StatelessWidget {
  final OrganizationEntity organization;
  final bool isOwnedByMe;
  final VoidCallback onTap;

  const OrganizationCard({
    super.key,
    required this.organization,
    required this.onTap,
    this.isOwnedByMe = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPrivate = organization.visibility == OrganizationVisibility.private;
    final ownerAccent = isDark ? const Color(0xffC4B5FD) : AppColors.lavender;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          splashColor: AppColors.primary.withValues(alpha: 0.06),
          highlightColor: AppColors.primary.withValues(alpha: 0.03),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: isOwnedByMe
                  ? ownerAccent.withValues(alpha: isDark ? 0.10 : 0.08)
                  : colors.surface,
              border: Border.all(
                color: isOwnedByMe
                    ? ownerAccent.withValues(alpha: isDark ? 0.46 : 1)
                    : Theme.of(context).dividerColor,
                width: isOwnedByMe ? 1.4 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _OrgLogo(organization: organization),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  organization.name,
                                  style: TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w800,
                                    color: colors.onSurface,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (organization.verified)
                                const Padding(
                                  padding: EdgeInsets.only(right: 6),
                                  child: Icon(
                                    Icons.verified_rounded,
                                    size: 18,
                                    color: Color(0xff0EA5E9),
                                  ),
                                ),
                              if (isOwnedByMe)
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Icon(
                                    Icons.workspace_premium_rounded,
                                    size: 18,
                                    color: ownerAccent,
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _VisibilityBadge(isPrivate: isPrivate),
                              if (organization.verified)
                                const _VerifiedBadge(),
                              if (isOwnedByMe) const _OwnerBadge(),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                if (organization.description != null &&
                    organization.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    organization.description!,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: colors.onSurfaceVariant,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                if (organization.ownerName != null ||
                    organization.membersCount > 0) ...[
                  const SizedBox(height: 14),
                  Container(height: 1, color: Theme.of(context).dividerColor),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (organization.ownerName != null) ...[
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_outline_rounded,
                            size: 13,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isOwnedByMe
                                ? 'أنت (المالك)'
                                : organization.ownerName!,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: isOwnedByMe
                                  ? ownerAccent
                                  : colors.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ] else
                        const Spacer(),

                      if (organization.membersCount > 0)
                        Row(
                          children: [
                            Icon(
                              Icons.people_alt_rounded,
                              size: 14,
                              color: colors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              organization.membersCount == 1
                                  ? 'عضو واحد'
                                  : '${organization.membersCount} أعضاء',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrgLogo extends StatelessWidget {
  final OrganizationEntity organization;

  const _OrgLogo({required this.organization});

  @override
  Widget build(BuildContext context) {
    final hasImage =
        organization.image != null && organization.image!.isNotEmpty;

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: hasImage
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.70),
                ],
              ),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              organization.image!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _initials(),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  child: const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                );
              },
            )
          : _initials(),
    );
  }

  Widget _initials() {
    final name = organization.name.trim();
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';

    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _VisibilityBadge extends StatelessWidget {
  final bool isPrivate;

  const _VisibilityBadge({required this.isPrivate});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badgeColor = isPrivate
        ? (isDark ? const Color(0xffFBBF24) : const Color(0xffB4780F))
        : (isDark ? const Color(0xff86EFAC) : const Color(0xff2E7D53));
    final backgroundColor = isDark
        ? badgeColor.withValues(alpha: 0.12)
        : (isPrivate
              ? AppColors.peach.withValues(alpha: 0.50)
              : AppColors.mint.withValues(alpha: 0.50));
    final label = isPrivate ? 'خاصة' : 'عامة';
    final icon = isPrivate ? Icons.lock_outline_rounded : Icons.public_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? badgeColor.withValues(alpha: 0.24)
              : colors.outlineVariant.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const accent = Color(0xff0EA5E9);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.18),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 12, color: accent),
          SizedBox(width: 4),
          Text(
            'موثقة',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnerBadge extends StatelessWidget {
  const _OwnerBadge();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? const Color(0xffC4B5FD) : AppColors.lavender;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.13 : 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? accent.withValues(alpha: 0.26)
              : colors.outlineVariant.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium_rounded, size: 12, color: accent),
          const SizedBox(width: 4),
          Text(
            'منظمتي',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}
