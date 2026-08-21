import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/all_courses_bloc.dart';
import '../bloc/all_courses_event.dart';
import '../bloc/all_courses_state.dart';
import '../bloc/course_details_bloc.dart';
import '../bloc/course_details_event.dart';
import '../widgets/course_card.dart';
import 'course_details_page.dart';
class AllCoursesPage extends StatelessWidget {
  const AllCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider(
      create: (_) => sl<AllCoursesBloc>()..add(LoadAllCoursesEvent()),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 28,
                  left: 22,
                  right: 22,
                  bottom: 24,
                ),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.08),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(34),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: colors.primary,
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'جميع الكورسات',
                      style: textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: BlocBuilder<AllCoursesBloc, AllCoursesState>(
                  builder: (context, state) {
                    if (state is AllCoursesLoading || state is AllCoursesInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is AllCoursesError) {
                      return Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(state.message),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => context.read<AllCoursesBloc>().add(LoadAllCoursesEvent()),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ]),
                      );
                    }
                    if (state is AllCoursesLoaded) {
                      if (state.courses.isEmpty) {
                        return Center(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.menu_book_rounded, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            const SizedBox(height: 16),
                            Text('لا توجد كورسات حالياً', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          ]),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async => context.read<AllCoursesBloc>().add(LoadAllCoursesEvent()),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 12, bottom: 100),
                          itemCount: state.courses.length,
                          itemBuilder: (context, index) {
                            final course = state.courses[index];
                            return CourseCard(
                              course: course,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider(
                                      create: (_) => sl<CourseDetailsBloc>()
                                        ..add(GetCourseDetailsEvent(
                                          orgSlug: course.organization?.slug ?? '',
                                          courseSlug: course.slug,
                                        )),
                                      child: const CourseDetailsPage(),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}