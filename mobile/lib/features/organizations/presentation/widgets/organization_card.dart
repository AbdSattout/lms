import 'package:flutter/material.dart';
import 'package:lms/features/profile/domain/entities/profile_entity.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/organization_entity.dart';

class OrganizationCard extends StatelessWidget {
  final OrganizationEntity organization;
  final VoidCallback onTap;
  const OrganizationCard({
    super.key,
    required this.organization,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isInviteOnly =
        organization.visibility == OrganizationVisibility.inviteOnly;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          splashColor: AppColors.primary.withOpacity(0.06),
          highlightColor: AppColors.primary.withOpacity(0.03),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.dark.withOpacity(0.04),
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
                          Text(
                            organization.name,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.dark,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 6),

                          _VisibilityBadge(isInviteOnly: isInviteOnly),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
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
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.darkSoft,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                if (organization.ownerName != null) ...[
                  const SizedBox(height: 14),
                  Container(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: AppColors.darkSoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          size: 13,
                          color: AppColors.darkSoft,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          organization.ownerName!,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkSoft,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
            AppColors.primary.withOpacity(0.7),
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
            color: AppColors.primaryLight,
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
  final bool isInviteOnly;

  const _VisibilityBadge({required this.isInviteOnly});

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
    isInviteOnly ? AppColors.peach.withOpacity(0.5) : AppColors.mint.withOpacity(0.5);
    final iconColor = isInviteOnly ? const Color(0xffB4780F) : const Color(0xff2E7D53);
    final label = isInviteOnly ? 'دعوة فقط' : 'عامة';
    final icon = isInviteOnly ? Icons.mail_outline_rounded : Icons.public_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}