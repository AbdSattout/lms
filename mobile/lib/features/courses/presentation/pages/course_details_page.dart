import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../organizations/presentation/bloc/organization_details_bloc.dart';
import '../../../organizations/presentation/bloc/organization_details_event.dart';
import '../../../posts/presentation/pages/course_posts_page.dart';
import '../../domain/entities/course_entity.dart';
import '../bloc/course_details_bloc.dart';
import '../bloc/course_details_event.dart';
import '../bloc/course_details_state.dart';
import 'course_contents_page.dart';
import '../../../organizations/presentation/pages/organization_details_page.dart';

class CourseDetailsPage extends StatelessWidget {
  const CourseDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: BlocConsumer<CourseDetailsBloc, CourseDetailsState>(
          listenWhen: (previous, current) =>
          current is CourseEnrollSuccess ||
              (current is CourseDetailsError && previous is CourseDetailsLoading),
          listener: (context, state) {
            if (state is CourseEnrollSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم تسجيلك في "${state.result.courseTitle}"')),
              );
            }
            if (state is CourseDetailsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          buildWhen: (previous, current) =>
          current is CourseDetailsLoading ||
              current is CourseDetailsLoaded ||
              (current is CourseDetailsError && previous is! CourseDetailsLoaded),
          builder: (context, state) {
            if (state is CourseDetailsLoading || state is CourseDetailsInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is CourseDetailsError) {
              return Center(child: Text(state.message, textAlign: TextAlign.center));
            }
            if (state is CourseDetailsLoaded) {
              return _CourseDetailsContent(
                course: state.course,
                onEnroll: () => context.read<CourseDetailsBloc>().add(EnrollEvent(state.course.id)),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _CourseDetailsContent extends StatelessWidget {
  final CourseEntity course;
  final VoidCallback onEnroll;

  const _CourseDetailsContent({required this.course, required this.onEnroll});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isEnrolled = course.enrollment != null;
    final viewerJoined = course.organization?.viewerJoined;
    final viewerRole = course.organization?.viewerRole;
    final isOwner = viewerRole == 'OWNER';
    final isBlockedByMembership = !isEnrolled && viewerJoined == false && !isOwner;
    final progressPercentage = course.enrollment?.progressPercentage ?? 0;
    final isCompleted = course.isCompleted;
    final hasCover = course.coverUrl != null && course.coverUrl!.isNotEmpty;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                    child: hasCover
                        ? Image.network(course.coverUrl!, height: 240, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _coverPlaceholder())
                        : _coverPlaceholder(),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _roundIconButton(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.maybePop(context)),
                        ],
                      ),
                    ),
                  ),
                  if (course.organizationDisplayName != null)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.apartment_rounded, size: 14, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(course.organizationDisplayName!, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.title, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: colors.onSurface, height: 1.3)),
                    const SizedBox(height: 16),

                    if (isEnrolled) ...[
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: colors.primary.withOpacity(0.15)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(isCompleted ? 'مكتمل 🎉' : 'قيد التقدم', style: TextStyle(fontWeight: FontWeight.w700, color: colors.primary, fontSize: 14)),
                                Text('${progressPercentage.toStringAsFixed(0)}%', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: colors.primary)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(value: progressPercentage / 100, minHeight: 8, backgroundColor: colors.surfaceContainerHighest, valueColor: AlwaysStoppedAnimation(colors.primary)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    if (course.description != null && course.description!.isNotEmpty) ...[
                      _SectionHeader(icon: Icons.info_outline_rounded, title: 'عن هذا الكورس'),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: colors.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
                        child: Text(course.description!, style: TextStyle(fontSize: 13.5, color: colors.onSurfaceVariant, height: 1.7)),
                      ),
                      const SizedBox(height: 24),
                    ],


                    Row(
                      children: [
                        Expanded(child: _StatCard(icon: Icons.people_alt_rounded, iconColor: colors.primary, iconBg: colors.primary.withOpacity(0.1), label: 'المنظمة', value: course.organizationDisplayName ?? '—')),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard(icon: Icons.speed_rounded, iconColor: const Color(0xffB4780F), iconBg: const Color(0xffB4780F).withOpacity(0.1), label: 'المستوى', value: 'قريباً')),
                      ],
                    ),
                    const SizedBox(height: 28),

                    _SectionHeader(icon: Icons.groups_rounded, title: 'مجتمع الكورس'),
                    const SizedBox(height: 12),
                    _FeatureCard(icon: Icons.forum_outlined, iconBg: colors.primary.withOpacity(0.1), iconColor: colors.primary, title: 'منشورات الكورس', subtitle: 'مناقشات وإعلانات', onTap: () =>   Navigator.push(context, MaterialPageRoute(builder: (_) => CoursePostsPage(courseSlug: course.slug))),
                    ),
                    const SizedBox(height: 10),
                    _FeatureCard(icon: Icons.chat_bubble_outline_rounded, iconBg: const Color(0xff2E7D53).withOpacity(0.1), iconColor: const Color(0xff2E7D53), title: 'محادثة المجموعة', subtitle: 'تواصل مع زملائك', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('محادثة المجموعة قريباً')))),
                  ],
                ),
              ),
            ],
          ),
        ),


        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: BoxDecoration(color: colors.surface, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))]),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: isOwner
                      ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أنت مالك المنظمة، لا يمكنك التسجيل في كورساتها')))
                      : isBlockedByMembership
                      ? () => _showMembershipRequiredDialog(context, course)
                      : isEnrolled
                      ? () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => CourseContentsPage(course: course)));
                    if (context.mounted) context.read<CourseDetailsBloc>().add(GetCourseDetailsEvent(orgSlug: course.organization?.slug ?? '', courseSlug: course.slug));
                  }
                      : onEnroll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOwner ? colors.surfaceContainerHighest : colors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  icon: Icon(isOwner ? Icons.admin_panel_settings_rounded : isEnrolled ? Icons.play_circle_fill_rounded : Icons.rocket_launch_rounded, color: isOwner ? colors.onSurfaceVariant : Colors.white),
                  label: Text(isOwner ? 'أنت مالك المنظمة' : isEnrolled ? 'متابعة التعلم' : 'سجّل الآن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isOwner ? colors.onSurfaceVariant : Colors.white)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      height: 240, width: double.infinity,
      decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withOpacity(0.6)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: const Center(child: Icon(Icons.menu_book_rounded, color: Colors.white, size: 56)),
    );
  }

  Widget _roundIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), shape: BoxShape.circle), child: Icon(icon, size: 18, color: AppColors.dark)),
    );
  }

  void _showMembershipRequiredDialog(BuildContext context, CourseEntity course) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('يجب الانضمام إلى المنظمة أولاً'),
          content: Text(course.organizationDisplayName != null ? 'التسجيل في هذا الكورس يتطلب أن تكون عضواً في "${course.organizationDisplayName}".' : 'التسجيل في هذا الكورس يتطلب عضوية المنظمة المالكة له.'),
          actions: [
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء'))),
                const SizedBox(width: 10),
                if (course.organization != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider(create: (_) => sl<OrganizationDetailsBloc>()..add(GetOrganizationDetailsEvent(course.organization!.slug)), child: OrganizationDetailsPage(slug: course.organization!.slug))));
                        if (context.mounted) context.read<CourseDetailsBloc>().add(GetCourseDetailsEvent(orgSlug: course.organization!.slug, courseSlug: course.slug));
                      },
                      icon: const Icon(Icons.apartment_rounded, size: 18),
                      label: const Text('عرض المنظمة'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: colors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: colors.primary)),
        const SizedBox(width: 10),
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: colors.onSurface)),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureCard({required this.icon, required this.iconBg, required this.iconColor, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: colors.outlineVariant.withOpacity(0.5))),
          child: Row(
            children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)), child: Icon(icon, size: 22, color: iconColor)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: colors.onSurface)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
                ]),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  const _StatCard({required this.icon, required this.iconColor, required this.iconBg, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: Theme.of(context).dividerColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)), child: Icon(icon, size: 18, color: iconColor)),
        const SizedBox(height: 10),
        Text(label, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: colors.onSurface)),
      ]),
    );
  }
}
