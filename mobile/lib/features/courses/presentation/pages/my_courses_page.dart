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
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<MyCoursesBloc, MyCoursesState>(
          listenWhen: (previous, current) =>
          current is MyCoursesError,
          listener: (context, state) {
            if (state is MyCoursesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is MyCoursesLoading ||
                state is MyCoursesInitial) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is MyCoursesError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<MyCoursesBloc>()
                              .add(GetMyEnrollmentsEvent());
                        },
                        child: const Text(
                          'إعادة المحاولة',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is MyCoursesLoaded) {
              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      top: 24,
                      left: 22,
                      right: 22,
                      bottom: 22,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(34),
                      ),
                    ),
                    child: const Text(
                      'كورساتي',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  Expanded(
                    child: state.courses.isEmpty
                        ? const Center(
                      child: Text(
                        'لم تسجّل في أي كورس بعد',
                      ),
                    )
                        : RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<MyCoursesBloc>()
                            .add(
                          GetMyEnrollmentsEvent(),
                        );
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          top: 18,
                          bottom: 24,
                        ),
                        itemCount: state.courses.length,
                        itemBuilder: (
                            context,
                            index,
                            ) {
                          final course =
                          state.courses[index];

                          return CourseCard(
                            course: course,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CourseContentsPage(
                                        course: course,
                                      ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}