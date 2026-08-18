import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/assessments/practice_quiz/presentation/pages/practice_quiz_list_page.dart';

import '../../../../core/services/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/api_error_resolver.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../chat/domain/entities/conversation_entity.dart';
import '../../../chat/domain/usecases/get_course_conversation_usecase.dart';
import '../../../chat/presentation/bloc/chat_messages_bloc.dart';
import '../../../chat/presentation/bloc/chat_messages_event.dart';
import '../../../chat/presentation/pages/chat_room_page.dart';
import '../../../posts/presentation/pages/course_posts_page.dart';
import '../../../assessments/ai_quiz/presentation/pages/ai_quiz_page.dart';
import '../../../assessments/final_exam/presesntation/pages/final_exam_page.dart';
import '../../../assessments/practice_exam/presentation/pages/practice_exam_list_page.dart';
import '../../../assessments/random_quiz/presentation/pages/random_quiz_config_page.dart';
import '../../domain/entities/course_entity.dart';
import '../bloc/block_content_bloc.dart';
import '../bloc/course_contents_bloc.dart';
import '../bloc/course_contents_event.dart';
import '../bloc/course_contents_state.dart';
import '../widgets/course_feature_card.dart';
import 'lesson_content_page.dart';

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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
          final progress = displayCourse.learningProgressPercentage;
          final progressSnapshot = displayCourse.progressSnapshot;
          final isCompleted = displayCourse.isCompleted;
          final isFinalQuizUnlocked = progress >= 100;
          final placementTestCompleted =
              state is CourseContentsLoaded ||
              displayCourse.enrollment?.placementTestCompleted == true;
          final isStartingCourse = state is CourseContentsStartingCourse;
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
                                style: textTheme.headlineSmall?.copyWith(
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
                                        size: 15,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        displayCourse.organizationDisplayName!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 20),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isCompleted
                                        ? 'مكتمل 🎉'
                                        : isFinalQuizUnlocked
                                        ? 'جاهز للاختبار النهائي'
                                        : '${progress.toStringAsFixed(0)}% مكتمل',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: colors.primary,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    '${progress.toStringAsFixed(0)}%',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: colors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: (progress / 100).clamp(0, 1),
                                  minHeight: 8,
                                  backgroundColor:
                                      colors.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation(
                                    isCompleted
                                        ? const Color(0xff2E7D53)
                                        : colors.primary,
                                  ),
                                ),
                              ),

                              if (!isCompleted &&
                                  progressSnapshot != null &&
                                  progressSnapshot.currentBlockId != null) ...[
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colors.primary.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: colors.primary.withOpacity(0.12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: colors.primary.withOpacity(
                                            0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.location_on_rounded,
                                          size: 18,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'موقعك الحالي',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: colors.onSurfaceVariant,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'تابع من حيث توقفت',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: colors.onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => BlocProvider(
                                                create: (_) =>
                                                    sl<BlockContentBloc>(),
                                                child: LessonContentPage(
                                                  initialBlockId:
                                                      progressSnapshot
                                                          .currentBlockId ??
                                                      0,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.arrow_circle_left_sharp,
                                          size: 18,
                                        ),
                                        label: const Text(
                                          'استمر',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          foregroundColor: colors.primary,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        _SectionHeader(
                          icon: Icons.groups_rounded,
                          title: 'مجتمع الكورس',
                        ),
                        const SizedBox(height: 12),
                        CourseFeatureCard(
                          icon: Icons.forum_outlined,
                          iconBg: colors.primary.withOpacity(0.1),
                          iconColor: colors.primary,
                          title: 'منشورات الكورس',
                          subtitle: 'مناقشات وإعلانات',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CoursePostsPage(courseId: course.id),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        CourseFeatureCard(
                          icon: Icons.chat_bubble_outline_rounded,
                          iconBg: const Color(0xff2E7D53).withOpacity(0.1),
                          iconColor: const Color(0xff2E7D53),
                          title: 'محادثة المجموعة',
                          subtitle: 'تواصل مع زملائك',
                          onTap: () => _openCourseChat(context),
                        ),
                        const SizedBox(height: 28),

                        _SectionHeader(
                          icon: Icons.auto_awesome_rounded,
                          title: 'أدوات التعلم',
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: _ToolCard(
                                icon: Icons.psychology_rounded,
                                iconColor: const Color(0xff0D9488),
                                iconBg: const Color(
                                  0xff0D9488,
                                ).withOpacity(0.1),
                                title: 'اختبار AI',
                                subtitle: 'مراجعة من البلوكات المحلولة',
                                badge: 'بدون XP',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AiQuizPage(courseId: course.id),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ToolCard(
                                icon: Icons.casino_rounded,
                                iconColor: const Color(0xff7C3AED),
                                iconBg: const Color(
                                  0xff7C3AED,
                                ).withOpacity(0.1),
                                title: 'اختبار عشوائي',
                                subtitle: 'من بنك الأسئلة العام',
                                badge: 'بدون XP',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RandomQuizConfigPage(
                                        courseId: course.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: _ToolCard(
                                icon: Icons.quiz_rounded,
                                iconColor: const Color(0xffD97706),
                                iconBg: const Color(
                                  0xffD97706,
                                ).withOpacity(0.1),
                                title: 'اختبار تدريبي',
                                subtitle: 'تضعه المنظمة',
                                badge: 'بدون XP',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PracticeQuizListPage(
                                        courseId: course.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ToolCard(
                                icon: Icons.assignment_rounded,
                                iconColor: const Color(0xff2563EB),
                                iconBg: const Color(
                                  0xff2563EB,
                                ).withOpacity(0.1),
                                title: 'امتحان تدريبي',
                                subtitle: 'تضعه المنظمة',
                                badge: '+ XP',
                                badgeColor: const Color(0xff2E7D53),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PracticeExamListPage(
                                        courseId: course.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        _FinalQuizCard(
                          isCompleted: isCompleted,
                          isUnlocked: isFinalQuizUnlocked,
                          onTap: () async {
                            final completed = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    FinalExamPage(courseId: displayCourse.id),
                              ),
                            );
                            if (context.mounted && completed == true) {
                              context.read<CourseContentsBloc>().add(
                                GetCourseContentsEvent(displayCourse.id),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 28),
                        _SectionHeader(
                          icon: Icons.menu_book_rounded,
                          title: 'محتوى الدورة',
                        ),
                        const SizedBox(height: 14),

                        placementTestCompleted
                            ? BlocBuilder<
                                CourseContentsBloc,
                                CourseContentsState
                              >(
                                builder: (context, state) {
                                  if (state is CourseContentsLoading)
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 40,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  if (state is CourseUnenrolled)
                                    return const SizedBox();
                                  if (state is CourseContentsError)
                                    return _errorCard(
                                      context,
                                      colors,
                                      state.message,
                                    );
                                  if (state is CourseContentsLoaded) {
                                    if (state.course.chapters.isEmpty)
                                      return _comingSoonCard(colors);
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
                            : _startCoursePrompt(
                                context,
                                colors,
                                displayCourse,
                                isStartingCourse,
                              ),
                        const SizedBox(height: 24),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffD9534F),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                minimumSize: const Size.fromHeight(58),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () =>
                                  _showUnenrollConfirmation(context, course),
                              icon: const Icon(Icons.logout_rounded, size: 18),
                              label: const Text(
                                'إلغاء التسجيل',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
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

  void _openCourseChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _CourseChatGate(
          course: course,
          currentUserId: _currentUserId(context),
        ),
      ),
    );
  }

  int _currentUserId(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    if (state is Authenticated) return state.authEntity.user.id;
    if (state is AuthSuccess) return state.authEntity.user.id;
    return 0;
  }

  Widget _startCoursePrompt(
    BuildContext context,
    ColorScheme colors,
    CourseEntity displayCourse,
    bool isStartingCourse,
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
              Icons.play_circle_fill_rounded,
              size: 36,
              color: AppColors.lavender,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'الكورس جاهز للبدء',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ مباشرة وسيتم تجاوز اختبار تحديد المستوى.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: isStartingCourse
                  ? null
                  : () {
                      context.read<CourseContentsBloc>().add(
                        StartCourseContentsEvent(displayCourse.id),
                      );
                    },
              icon: isStartingCourse
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.2,
                      ),
                    )
                  : const Icon(Icons.play_circle_fill_rounded, size: 18),
              label: Text(
                isStartingCourse ? 'جارٍ بدء الكورس...' : 'ابدأ الكورس',
                style: const TextStyle(fontWeight: FontWeight.bold),
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
            onPressed: () => context.read<CourseContentsBloc>().add(
              GetCourseContentsEvent(course.id),
            ),
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

// silly widgets to help
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: colors.primary),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.badge,
    this.badgeColor,
    required this.onTap,
  });

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
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 20, color: iconColor),
                  ),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: (badgeColor ?? colors.onSurfaceVariant)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge!,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: badgeColor ?? colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10.5,
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

class _FinalQuizCard extends StatelessWidget {
  final bool isCompleted;
  final bool isUnlocked;
  final VoidCallback onTap;

  const _FinalQuizCard({
    required this.isCompleted,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accentColor = isCompleted
        ? const Color(0xff2E7D53)
        : isUnlocked
        ? const Color(0xffD9534F)
        : colors.onSurfaceVariant;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isCompleted || !isUnlocked ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentColor.withValues(alpha: 0.3)),
            gradient: LinearGradient(
              colors: [
                accentColor.withValues(alpha: 0.05),
                accentColor.withValues(alpha: 0.02),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.emoji_events_rounded,
                  size: 24,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الاختبار النهائي',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isCompleted
                          ? 'تم إكمال الاختبار النهائي والكورس'
                          : isUnlocked
                          ? 'جاهز الآن بعد إكمال الدروس'
                          : 'متاح بعد إكمال آخر درس',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isCompleted
                      ? 'مكتمل'
                      : isUnlocked
                      ? 'ابدأ'
                      : '+ XP',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
        ),
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
    final isCurrent = chapter.status == ContentStatus.current;
    final completedLessons = chapter.lessons
        .where((l) => l.status == ContentStatus.completed)
        .length;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCurrent
              ? colors.primary.withOpacity(0.4)
              : Theme.of(context).dividerColor,
          width: isCurrent ? 1.5 : 1,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: colors.primary.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: isLocked
                ? () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('أكمل الفصل السابق أولاً')),
                  )
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
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '$completedLessons / ${chapter.lessons.length} دروس',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            if (isCurrent) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'الحالي',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: isCurrent
            ? colors.primary.withOpacity(0.06)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isCurrent
            ? Border.all(color: colors.primary.withOpacity(0.2))
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isLocked
            ? () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('أكمل الدرس السابق أولاً')),
              )
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
                if (context.mounted)
                  context.read<CourseContentsBloc>().add(
                    GetCourseContentsEvent(courseId),
                  );
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
                    color: colors.primary,
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
    final size = small ? 16.0 : 24.0;
    switch (status) {
      case ContentStatus.completed:
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Color(0xff2E7D53),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
        );
      case ContentStatus.current:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            color: AppColors.primary,
            size: size * 0.7,
          ),
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

class _CourseChatGate extends StatefulWidget {
  final CourseEntity course;
  final int currentUserId;

  const _CourseChatGate({required this.course, required this.currentUserId});

  @override
  State<_CourseChatGate> createState() => _CourseChatGateState();
}

class _CourseChatGateState extends State<_CourseChatGate> {
  late Future<ConversationEntity> _future;
  bool _opened = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = sl<GetCourseConversationUseCase>().call(widget.course.id);
    _future.then((conversation) {
      if (!mounted || _opened) return;
      _opened = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => sl<ChatMessagesBloc>(
                param1: conversation.id,
                param2: widget.currentUserId,
              )..add(OpenChatConversationEvent()),
              child: ChatRoomPage(
                conversationId: conversation.id,
                title: widget.course.title,
                isCourseChat: true,
              ),
            ),
          ),
        );
      });
    });
  }

  void _retry() {
    setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: FutureBuilder<ConversationEntity>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              final error = snapshot.error;
              return _CourseChatGateError(
                message: error != null
                    ? resolveApiErrorMessage(error)
                    : 'تعذر فتح المحادثة',
                onRetry: _retry,
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class _CourseChatGateError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CourseChatGateError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
