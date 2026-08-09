import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/placement_test_entity.dart';
import '../bloc/placement_test_bloc.dart';
import '../bloc/placement_test_event.dart';
import '../bloc/placement_test_state.dart';

class PlacementTestPage extends StatefulWidget {
  final CourseEntity course;

  const PlacementTestPage({super.key, required this.course});

  @override
  State<PlacementTestPage> createState() => _PlacementTestPageState();
}

class _PlacementTestPageState extends State<PlacementTestPage> {
  static const int _heartCount = 2;

  @override
  void initState() {
    super.initState();
    context.read<PlacementTestBloc>().add(
      StartPlacementTestEvent(widget.course.id),
    );
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
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
            return _CompletedView(data: state.data);
          }

          if (state is PlacementTestInProgress) {
            final question = state.data.question;
            final heartsRemaining = state.heartsRemaining
                .clamp(0, _heartCount)
                .toInt();

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      for (int i = 0; i < _heartCount; i++)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: SizedBox(
                            width: 26,
                            height: 26,
                            child: AnimatedOpacity(
                              opacity: i < heartsRemaining ? 1 : 0,
                              duration: const Duration(milliseconds: 240),
                              curve: Curves.easeOut,
                              child: const Icon(
                                Icons.favorite_rounded,
                                color: Color(0xffE0577B),
                                size: 26,
                              ),
                            ),
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
                  if (question == null)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
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
                          final isSubmitted =
                              state.submittedAnswerIndex == index;
                          final isChecking = state.isSubmitting && isSubmitted;
                          final hasFeedback =
                              state.lastAnswerCorrect != null && isSubmitted;

                          Color? tileColor;
                          Color borderColor = Theme.of(context).dividerColor;
                          Widget? trailingIcon;

                          if (hasFeedback) {
                            final correct = state.lastAnswerCorrect == true;
                            tileColor = correct
                                ? const Color(
                                    0xff2E7D53,
                                  ).withValues(alpha: 0.12)
                                : const Color(
                                    0xffD9534F,
                                  ).withValues(alpha: 0.12);
                            borderColor = correct
                                ? const Color(0xff2E7D53)
                                : const Color(0xffD9534F);
                            trailingIcon = Icon(
                              correct
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              color: borderColor,
                            );
                          }

                          if (isChecking) {
                            tileColor = colors.primary.withValues(alpha: 0.08);
                            borderColor = colors.primary;
                            trailingIcon = SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: colors.primary,
                              ),
                            );
                          }

                          final disabled =
                              state.isSubmitting ||
                              state.data.completed ||
                              state.lastAnswerCorrect == true ||
                              (state.lastAnswerCorrect == false && isSubmitted);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Material(
                              color: tileColor ?? colors.surface,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: disabled
                                    ? null
                                    : () {
                                        context.read<PlacementTestBloc>().add(
                                          SubmitPlacementAnswerEvent(index),
                                        );
                                      },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: borderColor,
                                      width: 1.4,
                                    ),
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
                        onPressed:
                            state.isSubmitting ||
                                state.data.completed ||
                                state.lastAnswerCorrect == true
                            ? null
                            : () {
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
  final PlacementTestStateEntity data;

  const _CompletedView({required this.data});

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
              color: AppColors.mint.withValues(alpha: 0.4),
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
                Navigator.pop(context, true);
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
