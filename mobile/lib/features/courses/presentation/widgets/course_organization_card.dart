import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../organizations/domain/entities/organization_entity.dart';
import '../../domain/entities/course_entity.dart';

class CourseOrganizationCard extends StatelessWidget {
  final CourseOrganizationRef organization;
  final VoidCallback onTap;

  const CourseOrganizationCard({super.key, required this.organization, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasImage = organization.image != null && organization.image!.isNotEmpty;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.primaryLight,
                ),
                clipBehavior: Clip.antiAlias,
                child: hasImage
                    ? Image.network(organization.image!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.apartment_rounded, color: colors.primary))
                    : Icon(Icons.apartment_rounded, color: colors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(organization.name, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: colors.onSurface)),
                    const SizedBox(height: 3),
                    Text(
                      organization.visibility == OrganizationVisibility.public ? 'عامة' : 'خاصة',
                      style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}