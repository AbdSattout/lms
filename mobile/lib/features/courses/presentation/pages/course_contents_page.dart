import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/course_entity.dart';

class CourseContentsPage extends StatelessWidget {
  final CourseEntity course;

  const CourseContentsPage({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final enrollment = course.enrollment;
    final progress = enrollment?.progressPercentage ?? 0;

    final hasCover =
        course.coverUrl != null &&
            course.coverUrl!.isNotEmpty;

    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,

      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 170,
            pinned: true,
            backgroundColor: AppColors.primary,
            elevation: 0,

            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [

                  hasCover
                      ? Image.network(
                    course.coverUrl!,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          Color(0xff5E9CC0),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),

                  Container(
                    color: Colors.black.withOpacity(.28),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -1),

              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Column(
                  children: [

                    Container(
                      padding: const EdgeInsets.all(22),

                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(24),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.08),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          Text(
                            course.title,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: colors.onSurface,
                            ),
                          ),

                          if (course.organizationName != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Row(
                                children: [

                                  const Icon(
                                    Icons.apartment_rounded,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),

                                  const SizedBox(width: 6),

                                  Text(
                                    course.organizationName!,
                                    style: TextStyle(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [

                              Text(
                                "التقدم",
                                style: TextStyle(
                                  color:
                                  colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              Text(
                                "${progress.toStringAsFixed(0)}%",
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          ClipRRect(
                            borderRadius:
                            BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value:
                              (progress / 100).clamp(0, 1),
                              minHeight: 9,
                              backgroundColor:
                              colors.surfaceContainerHighest,
                              valueColor:
                              const AlwaysStoppedAnimation(
                                AppColors.primary,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              progress == 100
                                  ? "مكتملة بالكامل 🎉"
                                  : "%تابع التعلم للوصول إلى 100",
                              style: TextStyle(
                                color:
                                colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        children: [

                          const Icon(
                            Icons.menu_book,
                            color: AppColors.primary,
                          ),

                          const SizedBox(width: 8),

                          Text(
                            "محتوى الدورة",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    _comingSoonCard(colors),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _comingSoonCard(ColorScheme colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 34,
      ),

      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(22),
      ),

      child: Column(
        children: [

          Container(
            width: 70,
            height: 70,

            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.12),
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.menu_book_rounded,
              size: 36,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            "سيتم عرض الفصول والدروس هنا",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: colors.onSurface,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "بانتظار اكتمال واجهة برمجة المحتوى من الخادم.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}