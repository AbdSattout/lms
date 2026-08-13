import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/my_courses_bloc.dart';
import '../bloc/my_courses_event.dart';
import '../bloc/my_courses_state.dart';
import '../widgets/course_card.dart';
import 'course_contents_page.dart';
import '../../../roadmaps/presentation/pages/my_roadmaps_page.dart';

class MyCoursesPage extends StatelessWidget {
  const MyCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 28, left: 22, right: 22, bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(34)),
              ),
              child: Column(
                children: [
                  Text(
                    'كورساتي',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Theme.of(context).colorScheme.onPrimary,
                      unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'كورساتي'),
                        Tab(text: 'مساراتي'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _CoursesTab(),
                  const MyRoadmapsPage(),
                ],
              ),
            ),
          ],
        ),
      ),

    );
  }
}

class _CoursesTab extends StatelessWidget {
  const _CoursesTab();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<MyCoursesBloc, MyCoursesState>(
      listenWhen: (previous, current) => current is MyCoursesError,
      listener: (context, state) {
        if (state is MyCoursesError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is MyCoursesLoading || state is MyCoursesInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is MyCoursesError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
                const SizedBox(height: 12),
                Text(state.message, textAlign: TextAlign.center, style: textTheme.bodyLarge),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<MyCoursesBloc>().add(GetMyEnrollmentsEvent()),
                  child: const Text('إعادة المحاولة'),
                ),
              ]),
            ),
          );
        }
        if (state is MyCoursesLoaded) {
          if (state.courses.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 80, height: 80, decoration: BoxDecoration(color: colors.primary.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.menu_book_rounded, size: 40, color: colors.primary)),
                const SizedBox(height: 16),
                Text('لم تسجّل في أي كورس بعد', style: textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant)),
              ]),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => context.read<MyCoursesBloc>().add(GetMyEnrollmentsEvent()),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 12, bottom: 100),
              itemCount: state.courses.length,
              itemBuilder: (context, index) {
                final course = state.courses[index];
                return CourseCard(
                  course: course,
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => CourseContentsPage(course: course)));
                    if (context.mounted) {
                      context.read<MyCoursesBloc>().add(GetMyEnrollmentsEvent());
                    }
                  },
                );
              },
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}