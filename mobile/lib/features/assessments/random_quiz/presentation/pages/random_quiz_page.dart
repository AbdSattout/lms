import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/presentation/widgets/quiz_option_tile.dart';
import '../bloc/random_quiz_bloc.dart';
import '../bloc/random_quiz_event.dart';
import '../bloc/random_quiz_state.dart';
import 'random_quiz_result_page.dart';

class RandomQuizPage extends StatefulWidget {
  final int courseId;
  const RandomQuizPage({super.key, required this.courseId});

  @override
  State<RandomQuizPage> createState() => _RandomQuizPageState();
}

class _RandomQuizPageState extends State<RandomQuizPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الاختبار العشوائي')),
        body: BlocConsumer<RandomQuizBloc, RandomQuizState>(
          listener: (context, state) {
            if (state is RandomQuizCompleted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => RandomQuizResultPage(result: state.result)),
              );
            }
            if (state is RandomQuizFailed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return switch (state) {
              RandomQuizInitial() || RandomQuizGenerating() => const Center(child: CircularProgressIndicator()),
              RandomQuizSessionReady() => _buildQuiz(context, state),
              RandomQuizSubmitting() => _buildSubmitting(context),
              RandomQuizCompleted() => const SizedBox(),
              RandomQuizFailed() => _buildError(context, state.message),
            };
          },
        ),
      ),
    );
  }

  Widget _buildQuiz(BuildContext context, RandomQuizSessionReady state) {
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
              final question = state.session.questions[index];
              final selected = state.selectedAnswers[question.id];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سؤال ${index + 1} من ${state.totalQuestions}',
                      style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      question.content,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...question.options.asMap().entries.map((entry) {
                      return QuizOptionTile(
                        option: entry.value,
                        index: entry.key,
                        isSelected: selected == entry.key,
                        onTap: () {
                          context.read<RandomQuizBloc>().add(
                            RandomQuizAnswerSelected(
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
        _buildBottomNavigation(context, state),
      ],
    );
  }

  Widget _buildProgressHeader(BuildContext context, RandomQuizSessionReady state) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('أجبت على ${state.answeredCount} من ${state.totalQuestions}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.onSurfaceVariant)),
              Text('${((state.answeredCount / state.totalQuestions) * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: colors.primary)),
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

  Widget _buildBottomNavigation(BuildContext context, RandomQuizSessionReady state) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentIndex > 0)
              OutlinedButton(
                onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
                child: const Text('السابق'),
              ),
            const Spacer(),
            if (_currentIndex < state.totalQuestions - 1)
              ElevatedButton(
                onPressed: state.selectedAnswers.containsKey(state.session.questions[_currentIndex].id)
                    ? () => _pageController.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.check_rounded),
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
          title: const Text('إنهاء الاختبار'),
          content: const Text('هل أنت متأكد من إنهاء الاختبار وإرسال إجاباتك؟'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<RandomQuizBloc>().add(SubmitRandomQuizRequested());
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