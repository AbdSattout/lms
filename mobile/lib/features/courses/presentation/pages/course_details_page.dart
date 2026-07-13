import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/course_entity.dart';
import '../bloc/course_details_bloc.dart';
import '../bloc/course_details_event.dart';
import '../bloc/course_details_state.dart';

class CourseDetailsPage extends StatefulWidget {
  const CourseDetailsPage({super.key});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  // i will replace it with course.isEnrolled once the backend adds one.
  bool _justEnrolled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FA),
      body: BlocConsumer<CourseDetailsBloc, CourseDetailsState>(
        listenWhen: (previous, current) =>
        current is CourseEnrollSuccess || current is CourseDetailsError,
        listener: (context, state) {
          if (state is CourseEnrollSuccess) {
            setState(() => _justEnrolled = true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم تسجيلك في "${state.enrollment.courseTitle}"'),
              ),
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
            return Center(
              child: Text(
                state.message,
                textAlign: TextAlign.center,
              ),
            );
          }

          if (state is CourseDetailsLoaded) {
            return _CourseDetailsContent(
              course: state.course,
              justEnrolled: _justEnrolled,
              onEnroll: () {
                context
                    .read<CourseDetailsBloc>()
                    .add(EnrollEvent(state.course.id));
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class _CourseDetailsContent extends StatelessWidget {
  final CourseEntity course;
  final bool justEnrolled;
  final VoidCallback onEnroll;

  const _CourseDetailsContent({
    required this.course,
    required this.justEnrolled,
    required this.onEnroll,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercentage = course.progress?.progressPercentage ?? 0;
    final isCompleted = course.progress?.completed == true;
    final hasCover = course.coverUrl != null && course.coverUrl!.isNotEmpty;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(28),
                    ),
                    child: hasCover
                        ? Image.network(
                      course.coverUrl!,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _coverPlaceholder(),
                    )
                        : _coverPlaceholder(),
                  ),

                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _roundIconButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () => Navigator.maybePop(context),
                          ),
                          Row(
                            children: [
                              _roundIconButton(
                                icon: Icons.share_outlined,
                                onTap: () {},
                              ),
                              const SizedBox(width: 10),
                              _roundIconButton(
                                icon: Icons.bookmark_border_rounded,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (course.organizationName != null)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          course.organizationName!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
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
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.dark,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (course.description != null &&
                        course.description!.isNotEmpty) ...[
                      Row(
                        children: const [
                          Icon(Icons.info_outline_rounded,
                              size: 18, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'عن هذا الكورس',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.dark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.greyLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          course.description!,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: AppColors.darkSoft,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Stat cards — using what the API actually gives us
                    // (progress) rather than the level/duration/XP shown
                    // in the Figma mock, which aren't backed by real
                    // fields yet. A "chapters" count card would be a good
                    // addition once that field is modeled and populated
                    // by the backend (currently comes back empty).
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: isCompleted
                                ? Icons.emoji_events_rounded
                                : Icons.trending_up_rounded,
                            iconColor: isCompleted
                                ? const Color(0xff2E7D53)
                                : const Color(0xffB4780F),
                            iconBg: isCompleted
                                ? AppColors.mint.withOpacity(0.5)
                                : AppColors.peach.withOpacity(0.5),
                            label: 'التقدم',
                            value: isCompleted
                                ? 'مكتمل'
                                : '${progressPercentage.toStringAsFixed(0)}٪',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.apartment_rounded,
                            iconColor: AppColors.primary,
                            iconBg: AppColors.primaryLight,
                            label: 'المنظمة',
                            value: course.organizationName ?? '—',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Fixed enroll button
        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: justEnrolled ? null : onEnroll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.darkSoft,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 4,
                ),
                icon: Icon(
                  justEnrolled
                      ? Icons.check_circle_rounded
                      : Icons.rocket_launch_rounded,
                  color: Colors.white,
                ),
                label: Text(
                  justEnrolled ? 'تم التسجيل' : 'سجّل الآن',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.6)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.menu_book_rounded, color: Colors.white, size: 56),
      ),
    );
  }

  Widget _roundIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: AppColors.dark),
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

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.darkSoft,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.dark,
            ),
          ),
        ],
      ),
    );
  }
}