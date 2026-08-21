import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/services/injection_container.dart';
import '../../domain/entities/practice_exam_summary_entity.dart';
import '../bloc/practice_exam_bloc.dart';
import '../bloc/practice_exam_event.dart';
import '../bloc/practice_exam_state.dart';
import 'practice_exam_page.dart';

class PracticeExamListPage extends StatelessWidget {
  final int courseId;
  const PracticeExamListPage({super.key, required this.courseId});

  void _navigateToExam(BuildContext context, int examId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeExamPage(
          courseId: courseId,
          examId: examId,
        ),
      ),
    );
  }

  void _handleExamTap(BuildContext context, PracticeExamSummaryEntity exam) {
    if (exam.hasStarted) {
      _navigateToExam(context, exam.id);
    } else {
      _showStartExamDialog(context, exam);
    }
  }

  void _showStartExamDialog(
      BuildContext context,
      PracticeExamSummaryEntity exam,
      ) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Row(
            children: [
              Icon(Icons.timer_rounded, color: colors.primary),
              const SizedBox(width: 8),
              const Text('بدء الامتحان'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(exam.title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              if (exam.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(exam.description, style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  _InfoChip(icon: Icons.timer_outlined, label: '${exam.timeLimitMinutes ?? '—'} دقيقة'),
                  const SizedBox(width: 12),
                  _InfoChip(icon: Icons.menu_book_rounded, label: '${exam.questionCount} سؤال'),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.error.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 18, color: colors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'سيبدأ المؤقت فوراً ولن يتوقف عند مغادرة الصفحة.',
                        style: TextStyle(fontSize: 12, color: colors.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _navigateToExam(context, exam.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                ),
                child: const Text('بدء الامتحان'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PracticeExamBloc>()..add(LoadPracticeExamList(courseId)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: const Text('الامتحانات التدريبية')),
          body: BlocBuilder<PracticeExamBloc, PracticeExamState>(
            builder: (context, state) {
              return switch (state) {
                PracticeExamInitial() || PracticeExamListLoading() => const Center(child: CircularProgressIndicator()),
                PracticeExamListLoaded() => RefreshIndicator(
                  onRefresh: () async => context.read<PracticeExamBloc>().add(LoadPracticeExamList(courseId)),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.exams.length,
                    itemBuilder: (context, index) {
                      final exam = state.exams[index];
                      return _PracticeExamCard(
                        exam: exam,
                        onTap: () => _handleExamTap(context, exam),
                      );
                    },
                  ),
                ),
                PracticeExamListEmpty() => Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.assignment_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text('لا توجد امتحانات تدريبية حالياً', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ]),
                ),
                PracticeExamDetailsLoading() => const Center(child: CircularProgressIndicator()),
                PracticeExamDetailsReady() => const SizedBox(),
                PracticeExamSubmitting() => const SizedBox(),
                PracticeExamCompleted() => const SizedBox(),
                PracticeExamFailed() => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => context.read<PracticeExamBloc>().add(LoadPracticeExamList(courseId)),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ]),
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.primary),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary)),
        ],
      ),
    );
  }
}

class _PracticeExamCard extends StatelessWidget {
  final PracticeExamSummaryEntity exam;
  final VoidCallback onTap;

  const _PracticeExamCard({required this.exam, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final difficultyLabel = switch (exam.difficulty?.toUpperCase()) {
      'EASY' => 'سهل',
      'HARD' => 'صعب',
      _ => 'متوسط',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
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
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.assignment_rounded, color: colors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(exam.title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: colors.onSurface)),
                  if (exam.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(exam.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
                  ],
                  const SizedBox(height: 8),
                  Wrap(spacing: 12, runSpacing: 4, children: [
                    Text(difficultyLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary)),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.timer_outlined, size: 13, color: colors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${exam.timeLimitMinutes ?? '—'} دقيقة', style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
                    ]),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.menu_book_rounded, size: 13, color: colors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${exam.questionCount} أسئلة', style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
                    ]),
                  ]),
                ]),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: colors.onSurfaceVariant),
            ]),
          ),
        ),
      ),
    );
  }
}