import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/course_entity.dart';
import '../bloc/block_content_bloc.dart';
import '../bloc/course_contents_bloc.dart';
import '../bloc/course_contents_event.dart';
import '../bloc/course_contents_state.dart';
import '../bloc/placement_test_bloc.dart';
import 'lesson_content_page.dart';
import 'placement_test_page.dart';

class CourseContentsPage extends StatelessWidget {
  final CourseEntity course;

  const CourseContentsPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<CourseContentsBloc>()..add(GetCourseContentsEvent(course.id)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: _CourseContentsView(course: course),
      ),
    );
  }
}

class _CourseContentsView extends StatefulWidget {
  final CourseEntity course;

  const _CourseContentsView({required this.course});

  @override
  State<_CourseContentsView> createState() => _CourseContentsViewState();
}

class _CourseContentsViewState extends State<_CourseContentsView> {
  CourseEntity get course => widget.course;

  bool _placementCompletedLocally = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: BlocConsumer<CourseContentsBloc, CourseContentsState>(
        listener: (context, state) {
          if (state is CourseUnenrolled) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context, true);
          }
          if (state is CourseContentsError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final displayCourse = state is CourseContentsLoaded
              ? state.course
              : course;
          final progress =
              displayCourse.progressSnapshot?.progressPercentage ??
              displayCourse.enrollment?.progressPercentage ??
              0.0;
          final placementTestCompleted =
              _placementCompletedLocally ||
              state is CourseContentsLoaded ||
              displayCourse.enrollment?.placementTestCompleted == true;
          final hasCover =
              displayCourse.coverUrl != null &&
              displayCourse.coverUrl!.isNotEmpty;

          return CustomScrollView(
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
                              displayCourse.coverUrl!,
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
                      Container(color: Colors.black.withOpacity(.28)),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayCourse.title,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: colors.onSurface,
                                ),
                              ),
                              if (displayCourse.organizationDisplayName != null)
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
                                        displayCourse.organizationDisplayName!,
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
                                      color: colors.onSurfaceVariant,
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
                                borderRadius: BorderRadius.circular(20),
                                child: LinearProgressIndicator(
                                  value: (progress / 100).clamp(0, 1),
                                  minHeight: 9,
                                  backgroundColor:
                                      colors.surfaceContainerHighest,
                                  valueColor: const AlwaysStoppedAnimation(
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
                                      : "تابع التعلم للوصول إلى 100%",
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('منشورات الكورس قريباً'),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.forum_outlined,
                                  size: 18,
                                ),
                                label: const Text('منشورات الكورس'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xffD9534F),
                                  side: const BorderSide(
                                    color: Color(0xffD9534F),
                                  ),
                                ),
                                onPressed: () {
                                  _showUnenrollConfirmation(context, course);
                                },
                                icon: const Icon(
                                  Icons.logout_rounded,
                                  size: 18,
                                ),
                                label: const Text('إلغاء التسجيل'),
                              ),
                            ),
                          ],
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

                        placementTestCompleted
                            ? BlocBuilder<
                                CourseContentsBloc,
                                CourseContentsState
                              >(
                                builder: (context, state) {
                                  if (state is CourseContentsLoading) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 40,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  if (state is CourseUnenrolled) {
                                    return const SizedBox();
                                  }
                                  if (state is CourseContentsError) {
                                    return _errorCard(
                                      context,
                                      colors,
                                      state.message,
                                    );
                                  }
                                  if (state is CourseContentsLoaded) {
                                    if (state.course.chapters.isEmpty) {
                                      return _comingSoonCard(colors);
                                    }
                                    return _chaptersList(
                                      context,
                                      colors,
                                      state.course.chapters,
                                      course.id,
                                    );
                                  }
                                  return const SizedBox();
                                },
                              )
                            : _placementTestPrompt(
                                context,
                                colors,
                                displayCourse,
                              ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _placementTestPrompt(
    BuildContext context,
    ColorScheme colors,
    CourseEntity displayCourse,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: BoxDecoration(
        color: AppColors.lavender.withOpacity(0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.lavender.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.lavender.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology_alt_rounded,
              size: 36,
              color: AppColors.lavender,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'حدد نقطة بدايتك أولاً',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اختبار قصير يحدد أنسب نقطة للبدء بها في هذه الدورة',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () async {
                final completed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => sl<PlacementTestBloc>(),
                      child: PlacementTestPage(course: displayCourse),
                    ),
                  ),
                );

                if (context.mounted && completed == true) {
                  setState(() => _placementCompletedLocally = true);
                  context.read<CourseContentsBloc>().add(
                    GetCourseContentsEvent(displayCourse.id),
                  );
                }
              },
              child: const Text(
                'ابدأ اختبار تحديد المستوى',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard(BuildContext context, ColorScheme colors, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              context.read<CourseContentsBloc>().add(
                GetCourseContentsEvent(course.id),
              );
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _chaptersList(
    BuildContext context,
    ColorScheme colors,
    List<ChapterEntity> chapters,
    int courseId,
  ) {
    return Column(
      children: chapters
          .map((chapter) => _ChapterCard(chapter: chapter, courseId: courseId))
          .toList(),
    );
  }

  Widget _comingSoonCard(ColorScheme colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
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
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

void _showUnenrollConfirmation(BuildContext context, CourseEntity course) {
  showDialog(
    context: context,
    builder: (dialogContext) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('إلغاء التسجيل'),
        content: Text('هل أنت متأكد من إلغاء التسجيل في "${course.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('تراجع'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffD9534F),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CourseContentsBloc>().add(
                UnenrollFromCourseEvent(course.id),
              );
            },
            child: const Text('تأكيد الإلغاء'),
          ),
        ],
      ),
    ),
  );
}

// Include _ChapterCard, _ChapterCardState, _LessonRow, _StatusIcon classes unchanged
class _ChapterCard extends StatefulWidget {
  final ChapterEntity chapter;
  final int courseId;
  const _ChapterCard({required this.chapter, required this.courseId});
  @override
  State<_ChapterCard> createState() => _ChapterCardState();
}

class _ChapterCardState extends State<_ChapterCard> {
  bool _expanded = false;
  @override
  void initState() {
    super.initState();
    _expanded = widget.chapter.status == ContentStatus.current;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final chapter = widget.chapter;
    final isLocked = chapter.status == ContentStatus.locked;
    final completedLessons = chapter.lessons
        .where((l) => l.status == ContentStatus.completed)
        .length;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: isLocked
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('أكمل الفصل السابق أولاً')),
                    );
                  }
                : () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _StatusIcon(status: chapter.status),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: isLocked
                                ? colors.onSurfaceVariant
                                : colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$completedLessons / ${chapter.lessons.length} دروس',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLocked)
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: colors.onSurfaceVariant,
                    ),
                ],
              ),
            ),
          ),
          if (_expanded && !isLocked)
            Padding(
              padding: const EdgeInsets.only(bottom: 8, right: 8, left: 8),
              child: Column(
                children: chapter.lessons
                    .map(
                      (lesson) =>
                          _LessonRow(lesson: lesson, courseId: widget.courseId),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  final LessonEntity lesson;
  final int courseId;
  const _LessonRow({required this.lesson, required this.courseId});
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isLocked = lesson.status == ContentStatus.locked;
    final isCurrent = lesson.status == ContentStatus.current;
    final completedBlocks = lesson.blocks
        .where((b) => b.status == ContentStatus.completed)
        .length;
    return Material(
      color: isCurrent
          ? AppColors.primaryLight.withOpacity(0.3)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: isLocked
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('أكمل الدرس السابق أولاً')),
                );
              }
            : () async {
                final currentBlocks = lesson.blocks.where(
                  (b) => b.status == ContentStatus.current,
                );
                final startBlockId = currentBlocks.isNotEmpty
                    ? currentBlocks.first.id
                    : lesson.blocks.first.id;
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => sl<BlockContentBloc>(),
                      child: LessonContentPage(initialBlockId: startBlockId),
                    ),
                  ),
                );
                if (context.mounted) {
                  context.read<CourseContentsBloc>().add(
                    GetCourseContentsEvent(courseId),
                  );
                }
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              _StatusIcon(status: lesson.status, small: true),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  lesson.title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                    color: isLocked
                        ? colors.onSurfaceVariant
                        : colors.onSurface,
                  ),
                ),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'متابعة',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                )
              else if (!isLocked)
                Text(
                  '$completedBlocks/${lesson.blocks.length}',
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final ContentStatus status;
  final bool small;
  const _StatusIcon({required this.status, this.small = false});
  @override
  Widget build(BuildContext context) {
    final size = small ? 16.0 : 22.0;
    switch (status) {
      case ContentStatus.completed:
        return Icon(
          Icons.check_circle_rounded,
          color: const Color(0xff2E7D53),
          size: size,
        );
      case ContentStatus.current:
        return Icon(
          Icons.play_circle_fill_rounded,
          color: AppColors.primary,
          size: size,
        );
      case ContentStatus.locked:
        return Icon(
          Icons.lock_rounded,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: size,
        );
      case ContentStatus.unknown:
        return Icon(
          Icons.circle_outlined,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: size,
        );
    }
  }
}
