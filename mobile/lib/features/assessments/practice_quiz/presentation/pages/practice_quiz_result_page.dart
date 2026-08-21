import 'package:flutter/material.dart';
import '../../../../../core/markdown/markdown_content_view.dart';
import '../../domain/entities/practice_quiz_submit_result_entity.dart';

class PracticeQuizResultPage extends StatelessWidget {
  final PracticeQuizSubmitResultEntity result;
  const PracticeQuizResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('نتيجة الاختبار')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ScoreCard(score: result.score, total: result.total, percentage: result.percentage),
              const SizedBox(height: 24),
              Text('مراجعة الإجابات', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              ...result.results.map((r) => _ResultTile(result: r)),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('العودة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final int score;
  final int total;
  final double percentage;

  const _ScoreCard({required this.score, required this.total, required this.percentage});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final passed = percentage >= 60;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: passed ? const Color(0xff2E7D53).withOpacity(0.3) : colors.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: passed ? const Color(0xff2E7D53).withOpacity(0.1) : colors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              passed ? Icons.check_circle_rounded : Icons.school_rounded,
              size: 40,
              color: passed ? const Color(0xff2E7D53) : colors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text('$score من $total', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, color: colors.onSurface)),
          const SizedBox(height: 4),
          Text('${percentage.toStringAsFixed(0)}%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: passed ? const Color(0xff2E7D53) : colors.primary)),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final dynamic result;

  const _ResultTile({required this.result});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isCorrect = result.correct == true;
    final selectedIndex = result.selectedAnswerIndex;
    final correctIndex = result.correctAnswerIndex;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect
              ? const Color(0xff2E7D53).withOpacity(0.3)
              : const Color(0xffD9534F).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCorrect
                      ? const Color(0xff2E7D53).withOpacity(0.1)
                      : const Color(0xffD9534F).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCorrect ? Icons.check_rounded : Icons.close_rounded,
                  size: 16,
                  color: isCorrect ? const Color(0xff2E7D53) : const Color(0xffD9534F),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MarkdownContentView(content: result.content),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (selectedIndex != null) ...[
            _AnswerRow(
              label: 'إجابتك',
              text: result.options[selectedIndex],
              color: isCorrect ? const Color(0xff2E7D53) : const Color(0xffD9534F),
            ),
            const SizedBox(height: 6),
          ],
          if (!isCorrect)
            _AnswerRow(
              label: 'الإجابة الصحيحة',
              text: result.options[correctIndex],
              color: const Color(0xff2E7D53),
            ),
        ],
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  final String label;
  final String text;
  final Color color;

  const _AnswerRow({required this.label, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: color),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}