import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/services/injection_container.dart';
import '../bloc/practice_quiz_bloc.dart';
import '../bloc/practice_quiz_event.dart';
import '../bloc/practice_quiz_state.dart';
import 'practice_quiz_page.dart';

class PracticeQuizListPage extends StatelessWidget {
  final int courseId;
  const PracticeQuizListPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PracticeQuizBloc>()..add(LoadPracticeQuizList(courseId)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: const Text('الاختبارات التدريبية')),
          body: BlocBuilder<PracticeQuizBloc, PracticeQuizState>(
            builder: (context, state) {
              return switch (state) {
                PracticeQuizInitial() || PracticeQuizListLoading() => const Center(child: CircularProgressIndicator()),
                PracticeQuizListLoaded() => RefreshIndicator(
                  onRefresh: () async {
                    context.read<PracticeQuizBloc>().add(LoadPracticeQuizList(courseId));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.quizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = state.quizzes[index];
                      return _PracticeQuizCard(
                        quiz: quiz,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PracticeQuizPage(
                                courseId: courseId,
                                quizId: quiz.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                PracticeQuizListEmpty() => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.quiz_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(height: 16),
                      Text('لا توجد اختبارات تدريبية حالياً', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                PracticeQuizDetailsLoading() => const Center(child: CircularProgressIndicator()),
                PracticeQuizDetailsReady() => const SizedBox(),
                PracticeQuizSubmitting() => const SizedBox(),
                PracticeQuizCompleted() => const SizedBox(),
                PracticeQuizFailed() => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.message, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => context.read<PracticeQuizBloc>().add(LoadPracticeQuizList(courseId)),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _PracticeQuizCard extends StatelessWidget {
  final dynamic quiz;
  final VoidCallback onTap;

  const _PracticeQuizCard({required this.quiz, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final difficultyLabel = switch (quiz.difficulty?.toUpperCase()) {
      'EASY' => 'سهل',
      'HARD' => 'صعب',
      _ => 'متوسط',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.quiz_rounded, color: colors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(quiz.title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: colors.onSurface)),
                  if (quiz.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(quiz.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
                  ],
                  const SizedBox(height: 8),
                  Row(children: [
                    Text(difficultyLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary)),
                    const SizedBox(width: 12),
                    Icon(Icons.menu_book_rounded, size: 13, color: colors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('${quiz.questionCount} أسئلة', style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
                  ]),
                ]),
              ),
              Icon(Icons.arrow_back_ios_rounded, size: 14, color: colors.onSurfaceVariant),
            ]),
          ),
        ),
      ),
    );
  }
}