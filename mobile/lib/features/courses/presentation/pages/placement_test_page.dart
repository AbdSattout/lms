import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/placement_test_entity.dart';
import '../bloc/placement_test_bloc.dart';
import '../bloc/placement_test_event.dart';
import '../bloc/placement_test_state.dart';
import 'course_contents_page.dart';

class PlacementTestPage extends StatefulWidget {
  final CourseEntity course;

  const PlacementTestPage({
    super.key,
    required this.course,
  });

  @override
  State<PlacementTestPage> createState() => _PlacementTestPageState();
}

class _PlacementTestPageState extends State<PlacementTestPage> {
  int? _selectedIndex;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    context.read<PlacementTestBloc>().add(
      StartPlacementTestEvent(widget.course.id),
    );
  }

  void _selectAnswer(int index) {
    if (_answered) return;

    setState(() {
      _selectedIndex = index;
      _answered = true;
    });

    context.read<PlacementTestBloc>().add(
      SubmitPlacementAnswerEvent(index),
    );

    Timer(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          _selectedIndex = null;
          _answered = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'اختبار تحديد المستوى',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<PlacementTestBloc, PlacementTestState>(
        listener: (context, state) {
          if (state is PlacementTestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is PlacementTestLoading || state is PlacementTestInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PlacementTestError) {
            return Center(
              child: Text(state.message, textAlign: TextAlign.center),
            );
          }

          if (state is PlacementTestCompleted) {
            return _CompletedView(
              course: widget.course,
              data: state.data,
            );
          }

          if (state is PlacementTestInProgress) {
            final question = state.data.question;
            if (question == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      for (int i = 0; i < 2; i++)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Icon(
                            i < state.heartsRemaining
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: i < state.heartsRemaining
                                ? const Color(0xffE0577B)
                                : colors.onSurfaceVariant,
                            size: 26,
                          ),
                        ),
                      const Spacer(),
                      Text(
                        '${state.data.correctAnswers}/${state.data.totalAnswers}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Text(
                      question.content,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: ListView.builder(
                      itemCount: question.options.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedIndex == index;

                        Color? tileColor;
                        Color borderColor = Theme.of(context).dividerColor;
                        Widget? trailingIcon;

                        if (_answered && isSelected) {
                          final correct = state.lastAnswerCorrect == true;
                          tileColor = correct
                              ? const Color(0xff2E7D53).withOpacity(0.12)
                              : const Color(0xffD9534F).withOpacity(0.12);
                          borderColor =
                          correct ? const Color(0xff2E7D53) : const Color(0xffD9534F);
                          trailingIcon = Icon(
                            correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: borderColor,
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: tileColor ?? colors.surface,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _selectAnswer(index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: borderColor, width: 1.4),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        question.options[index],
                                        style: TextStyle(
                                          fontSize: 14.5,
                                          color: colors.onSurface,
                                        ),
                                      ),
                                    ),
                                    if (trailingIcon != null) trailingIcon,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        context.read<PlacementTestBloc>().add(
                          SkipPlacementTestEvent(),
                        );
                      },
                      child: Text(
                        'تخطي الاختبار',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class _CompletedView extends StatelessWidget {
  final CourseEntity course;
  final PlacementTestStateEntity data;

  const _CompletedView({
    required this.course,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.mint.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              size: 46,
              color: Color(0xff2E7D53),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'أحسنت! تم تحديد نقطة بدايتك',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'أجبت بشكل صحيح على ${data.correctAnswers}أسئلة',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                final updatedEnrollment = CourseEnrollmentDetailsEntity(
                  id: course.enrollment?.id ?? 0,
                  courseId: course.id,
                  courseTitle: course.title,
                  enrolledAt: course.enrollment?.enrolledAt,
                  status: course.enrollment?.status ?? 'ACTIVE',
                  placementTestCompleted: true,
                  progressPercentage: data.progressPercentage,
                  currentChapterId: data.startChapterId,
                  currentLessonId: data.startLessonId,
                  currentBlockId: data.startBlockId,
                );

                final updatedCourse = CourseEntity(
                  id: course.id,
                  title: course.title,
                  slug: course.slug,
                  description: course.description,
                  coverUrl: course.coverUrl,
                  organizationName: course.organizationName,
                  status: course.status,
                  enrollment: updatedEnrollment,
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CourseContentsPage(course: updatedCourse),
                  ),
                );
              },
              child: const Text(
                'ابدأ التعلم',
                style: TextStyle(
                  fontSize: 16,
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
}