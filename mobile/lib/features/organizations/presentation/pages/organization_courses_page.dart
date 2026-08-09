import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../courses/presentation/bloc/course_details_bloc.dart';
import '../../../courses/presentation/bloc/course_details_event.dart';
import '../../../courses/presentation/pages/course_details_page.dart';
import '../../../courses/presentation/widgets/course_card.dart';
import '../bloc/organization_courses_bloc.dart';
import '../bloc/organization_courses_event.dart';
import '../bloc/organization_courses_state.dart';

class OrganizationCoursesPage extends StatelessWidget {
  final String slug;

  const OrganizationCoursesPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrganizationCoursesBloc>()
        ..add(GetOrganizationCoursesEvent(slug)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('كورسات المنظمة'),
          ),
          body: BlocBuilder<OrganizationCoursesBloc, OrganizationCoursesState>(
            builder: (context, state) {
              if (state is OrganizationCoursesLoading ||
                  state is OrganizationCoursesInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is OrganizationCoursesError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.message, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            context.read<OrganizationCoursesBloc>().add(
                              GetOrganizationCoursesEvent(slug),
                            );
                          },
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is OrganizationCoursesLoaded) {
                if (state.courses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.menu_book_rounded,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد كورسات في هذه المنظمة حالياً',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<OrganizationCoursesBloc>().add(
                      GetOrganizationCoursesEvent(slug),
                    );
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
      ),
    );
  }
}