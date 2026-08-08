import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/my_courses_bloc.dart';
import '../bloc/my_courses_event.dart';
import '../bloc/my_courses_state.dart';
import '../widgets/course_card.dart';
import 'course_contents_page.dart';

class MyCoursesPage extends StatelessWidget {
  const MyCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
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
              color: colors.primary.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(34),
              ),
            ),
            child: Text(
              'كورساتي',
              style: textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: colors.primary,
              ),
            ),
          ),

          Expanded(
            child: BlocConsumer<MyCoursesBloc, MyCoursesState>(
              listenWhen: (previous, current) => current is MyCoursesError,
              listener: (context, state) {
                if (state is MyCoursesError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline_rounded,
                              size: 48, color: colors.error),
                          const SizedBox(height: 12),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<MyCoursesBloc>()
                                  .add(GetMyEnrollmentsEvent());
                            },
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is MyCoursesLoaded) {
                  if (state.courses.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: colors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.menu_book_rounded,
                                size: 40, color: colors.primary),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لم تسجّل في أي كورس بعد',
                            style: textTheme.bodyLarge?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<MyCoursesBloc>()
                          .add(GetMyEnrollmentsEvent());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: state.courses.length,
                      itemBuilder: (context, index) {
                        final course = state.courses[index];
                        return CourseCard(
                          course: course,
                          onTap: () async {
                            final shouldRefresh = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CourseContentsPage(course: course),
                              ),
                            );
                            if (shouldRefresh == true && context.mounted) {
                              context
                                  .read<MyCoursesBloc>()
                                  .add(GetMyEnrollmentsEvent());
                            }
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
    );
  }
}