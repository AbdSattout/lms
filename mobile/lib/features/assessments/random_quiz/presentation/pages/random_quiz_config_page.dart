import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/services/injection_container.dart';
import '../bloc/random_quiz_bloc.dart';
import '../bloc/random_quiz_event.dart';
import 'random_quiz_page.dart';

class RandomQuizConfigPage extends StatefulWidget {
  final int courseId;
  const RandomQuizConfigPage({super.key, required this.courseId});

  @override
  State<RandomQuizConfigPage> createState() => _RandomQuizConfigPageState();
}

class _RandomQuizConfigPageState extends State<RandomQuizConfigPage> {
  String _difficulty = 'MEDIUM';
  int _count = 10;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('اختبار عشوائي')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('اختر مستوى الصعوبة', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: colors.onSurface)),
              const SizedBox(height: 12),
              _DifficultySelector(
                selected: _difficulty,
                onChanged: (value) => setState(() => _difficulty = value),
              ),
              const SizedBox(height: 28),
              Text('عدد الأسئلة', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: colors.onSurface)),
              const SizedBox(height: 12),
              _CountSelector(
                selected: _count,
                onChanged: (value) => setState(() => _count = value),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => sl<RandomQuizBloc>()
                            ..add(GenerateRandomQuizRequested(
                              courseId: widget.courseId,
                              difficulty: _difficulty,
                              count: _count,
                            )),
                          child: RandomQuizPage(courseId: widget.courseId),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.casino_rounded, size: 18),
                  label: const Text('توليد الاختبار', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultySelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _DifficultySelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final difficulties = [
      ('EASY', 'سهل', Icons.sentiment_satisfied_alt_rounded),
      ('MEDIUM', 'متوسط', Icons.sentiment_neutral_rounded),
      ('HARD', 'صعب', Icons.sentiment_dissatisfied_rounded),
    ];

    return Row(
      children: difficulties.map((d) {
        final isSelected = selected == d.$1;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _DifficultyCard(
              label: d.$2,
              icon: d.$3,
              isSelected: isSelected,
              onTap: () => onChanged(d.$1),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: isSelected ? colors.primary.withOpacity(0.1) : colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? colors.primary : colors.outlineVariant,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 24, color: isSelected ? colors.primary : colors.onSurfaceVariant),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isSelected ? colors.primary : colors.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _CountSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final presets = [5, 10, 15, 20];

    return Row(
      children: presets.map((count) {
        final isSelected = selected == count;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _CountChip(
              label: '$count',
              isSelected: isSelected,
              onTap: () => onChanged(count),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CountChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: isSelected ? colors.primary : colors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isSelected ? colors.primary : colors.outlineVariant),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isSelected ? colors.onPrimary : colors.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}