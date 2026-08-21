import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/markdown/markdown_content_view.dart';
import '../../../../../core/services/injection_container.dart';
import '../../../core/presentation/widgets/quiz_option_tile.dart';
import '../bloc/final_exam_bloc.dart';
import '../bloc/final_exam_event.dart';
import '../bloc/final_exam_state.dart';
import 'final_exam_result_page.dart';

class FinalExamPage extends StatefulWidget {
  final int courseId;
  const FinalExamPage({super.key, required this.courseId});

  @override
  State<FinalExamPage> createState() => _FinalExamPageState();
}

class _FinalExamPageState extends State<FinalExamPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FinalExamBloc>()..add(LoadFinalExam(widget.courseId)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: const Text('الاختبار النهائي')),
          body: BlocConsumer<FinalExamBloc, FinalExamState>(
            listener: (context, state) {
              if (state is FinalExamCompleted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FinalExamResultPage(result: state.result),
                  ),
                  result: true,
                );
              }
              if (state is FinalExamFailed) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              return switch (state) {
                FinalExamInitial() || FinalExamLoading() => const Center(child: CircularProgressIndicator()),
                FinalExamReady() => Scaffold(
                  body: _buildExam(context, state),
                  bottomNavigationBar: _buildBottomNavigation(context, state),  // ← Here
                ),
                FinalExamSubmitting() => _buildSubmitting(context),
                FinalExamCompleted() => const SizedBox(),
                FinalExamFailed() => _buildError(context, state.message),
              };
            },
          ),
        ),
      ),
    );
  }

  Widget _buildExam(BuildContext context, FinalExamReady state) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        _buildProgressHeader(context, state),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: state.totalQuestions,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final question = state.exam.questions[index];
              final selected = state.selectedAnswers[question.id];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سؤال ${index + 1} من ${state.totalQuestions}',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    MarkdownContentView(content: question.content),
                    const SizedBox(height: 24),
                    ...question.options.asMap().entries.map((entry) {
                      return QuizOptionTile(
                        option: entry.value,
                        index: entry.key,
                        isSelected: selected == entry.key,
                        onTap: () {
                          context.read<FinalExamBloc>().add(
                            FinalExamAnswerSelected(
                              questionId: question.id,
                              answerIndex: entry.key,
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgressHeader(BuildContext context, FinalExamReady state) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'أجبت على ${state.answeredCount} من ${state.totalQuestions}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
              Text(
                '${((state.answeredCount / state.totalQuestions) * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: state.answeredCount / state.totalQuestions,
              minHeight: 6,
              backgroundColor: colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(colors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context, FinalExamReady state) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentIndex > 0)
              OutlinedButton(
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(80, 44),
                ),
                child: const Text('السابق'),
              ),
            const Spacer(),
if (_currentIndex < state.totalQuestions - 1)
              ElevatedButton(
                onPressed: _isExpired
                    ? null
                    : () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  minimumSize: const Size(100, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('التالي'),
              )
            else
              ElevatedButton.icon(
                onPressed: state.allAnswered
                    ? () => _showSubmitConfirmation(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  minimumSize: const Size(140, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('إرسال الإجابات'),
              ),
          ],
        ),
      ),
    );
  }
  void _showSubmitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('إنهاء الاختبار النهائي'),
          content: const Text(
            'هل أنت متأكد من إنهاء الاختبار النهائي وإرسال إجاباتك؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<FinalExamBloc>().add(SubmitFinalExamRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('إرسال'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitting(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('جاري تصحيح الإجابات...'),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('العودة'),
            ),
          ],
        ),
      ),
    );
  }
}
