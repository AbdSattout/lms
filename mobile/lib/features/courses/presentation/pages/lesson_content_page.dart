import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/markdown/markdown_content_view.dart';
import '../../domain/entities/block_content_entity.dart'
    show BlockQuestionEntity;
import '../../domain/entities/course_entity.dart' show RewardEntity;
import '../bloc/block_content_bloc.dart';
import '../bloc/block_content_event.dart';
import '../bloc/block_content_state.dart';

class LessonContentPage extends StatefulWidget {
  final int initialBlockId;
  const LessonContentPage({super.key, required this.initialBlockId});

  @override
  State<LessonContentPage> createState() => _LessonContentPageState();
}

class _LessonContentPageState extends State<LessonContentPage> {
  int? _selectedIndex;
  int? _activeBlockId;
  int? _celebratedBlockId;
  int _wrongAttemptsForBlock = 0;
  int _confettiSeed = 0;
  bool _showConfetti = false;
  bool _progressChanged = false;

  @override
  void initState() {
    super.initState();
    context.read<BlockContentBloc>().add(LoadBlockEvent(widget.initialBlockId));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الدرس')),
        body: Stack(
          children: [
            BlocConsumer<BlockContentBloc, BlockContentState>(
              listener: (context, state) {
                if (state is BlockContentLoaded &&
                    _activeBlockId != state.block.id) {
                  setState(() {
                    _activeBlockId = state.block.id;
                    _celebratedBlockId = null;
                    _selectedIndex = null;
                    _wrongAttemptsForBlock = 0;
                    _showConfetti = false;
                  });
                }

                if (state is BlockContentLoaded &&
                    state.lastAnswerCorrect == false) {
                  setState(() => _wrongAttemptsForBlock += 1);
                }

                if (state is BlockContentLoaded &&
                    state.lastAnswerCorrect == true) {
                  _progressChanged = true;

                  final earnedXp = _earnedXp(
                    state.answerResult?.rewards ?? const [],
                  );
                  if (earnedXp > 0 && _celebratedBlockId != state.block.id) {
                    setState(() {
                      _celebratedBlockId = state.block.id;
                      _showConfetti = true;
                      _confettiSeed += 1;
                    });
                  }
                }

                if (state is BlockContentFinished) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                  Navigator.pop(context, _progressChanged);
                }

                if (state is BlockContentError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                if (state is BlockContentLoading ||
                    state is BlockContentFinished) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is BlockContentError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge,
                      ),
                    ),
                  );
                }

                if (state is BlockContentLoaded) {
                  final block = state.block;
                  final question = block.question;
                  final hasCorrectAnswer = state.lastAnswerCorrect == true;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          block.title,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),

                        MarkdownContentView(content: block.content),

                        if (question != null) ...[
                          const SizedBox(height: 28),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: colors.primary.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: colors.primary.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.help_outline_rounded,
                                    color: colors.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _DifficultyChip(question: question),
                                      const SizedBox(height: 10),
                                      MarkdownContentView(content: question.content),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          ...List.generate(question.options.length, (i) {
                            final selected = _selectedIndex == i;
                            final submitted = state.submittedAnswerIndex == i;
                            final wrong =
                                state.lastAnswerCorrect == false && submitted;
                            final correct =
                                state.lastAnswerCorrect == true && submitted;

                            Color borderColor = colors.outlineVariant;
                            Color bgColor = colors.surface;
                            IconData? leadingIcon;

                            if (wrong) {
                              borderColor = const Color(0xffD9534F);
                              bgColor = const Color(
                                0xffD9534F,
                              ).withValues(alpha: 0.05);
                              leadingIcon = Icons.close_rounded;
                            }
                            if (correct) {
                              borderColor = const Color(0xff2E7D53);
                              bgColor = const Color(
                                0xff2E7D53,
                              ).withValues(alpha: 0.05);
                              leadingIcon = Icons.check_rounded;
                            }
                            if (selected && !wrong && !correct) {
                              borderColor = colors.primary;
                              bgColor = colors.primary.withValues(alpha: 0.05);
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Material(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: state.isSubmitting || hasCorrectAnswer
                                      ? null
                                      : () =>
                                            setState(() => _selectedIndex = i),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: borderColor,
                                        width: selected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        if (leadingIcon != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 10,
                                            ),
                                            child: Icon(
                                              leadingIcon,
                                              size: 20,
                                              color: borderColor,
                                            ),
                                          ),
                                        Expanded(
                                          child: Text(
                                            question.options[i],
                                            style: textTheme.bodyLarge
                                                ?.copyWith(
                                                  color: colors.onSurface,
                                                  fontWeight: selected
                                                      ? FontWeight.w600
                                                      : FontWeight.w400,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),

                          if (state.lastAnswerCorrect == false)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline_rounded,
                                    size: 18,
                                    color: Color(0xffD9534F),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'إجابة خاطئة، حاول مجدداً',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xffD9534F),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (state.lastAnswerCorrect == true)
                            const SizedBox(height: 14),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.primary,
                                foregroundColor: colors.onPrimary,
                                disabledBackgroundColor: colors.primary
                                    .withValues(alpha: 0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              onPressed: state.isSubmitting
                                  ? null
                                  : hasCorrectAnswer
                                  ? () {
                                      _progressChanged = true;
                                      context.read<BlockContentBloc>().add(
                                        ContinueAfterCorrectAnswerEvent(),
                                      );
                                    }
                                  : (_selectedIndex == null ||
                                        _selectedIndex ==
                                            state.submittedAnswerIndex)
                                  ? null
                                  : () {
                                      context.read<BlockContentBloc>().add(
                                        SubmitBlockAnswerEvent(
                                          blockId: block.id,
                                          answerIndex: _selectedIndex!,
                                        ),
                                      );
                                    },
                              child: state.isSubmitting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.4,
                                      ),
                                    )
                                  : Text(
                                      hasCorrectAnswer
                                          ? 'المتابعة'
                                          : 'تحقق من الإجابة',
                                      style: textTheme.labelLarge?.copyWith(
                                        color: Colors.white,
                                      ),
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
            if (_showConfetti && _celebrationState() != null)
              _XpCelebrationOverlay(
                key: ValueKey(_confettiSeed),
                seed: _confettiSeed,
                state: _celebrationState()!,
                wrongAttempts: _wrongAttemptsForBlock,
                onContinue: () {
                  _progressChanged = true;
                  setState(() => _showConfetti = false);
                  context.read<BlockContentBloc>().add(
                    ContinueAfterCorrectAnswerEvent(),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  BlockContentLoaded? _celebrationState() {
    final current = context.read<BlockContentBloc>().state;
    if (current is BlockContentLoaded &&
        current.lastAnswerCorrect == true &&
        current.answerResult != null &&
        current.block.question != null) {
      return current;
    }

    return null;
  }
}

class _XpCelebrationOverlay extends StatelessWidget {
  final int seed;
  final BlockContentLoaded state;
  final int wrongAttempts;
  final VoidCallback onContinue;

  const _XpCelebrationOverlay({
    super.key,
    required this.seed,
    required this.state,
    required this.wrongAttempts,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final question = state.block.question!;

    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.42),
        child: Stack(
          children: [
            IgnorePointer(
              child: _ConfettiBurst(
                key: ValueKey('confetti-$seed'),
                seed: seed,
                onCompleted: () {},
              ),
            ),
            Center(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.92, end: 1),
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      final opacity = ((value - 0.92) / 0.08).clamp(0.0, 1.0);

                      return Opacity(
                        opacity: opacity,
                        child: Transform.scale(scale: value, child: child),
                      );
                    },
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: _XpCelebrationCard(
                        message: state.answerResult?.message,
                        rewards: state.answerResult?.rewards ?? const [],
                        question: question,
                        wrongAttempts: wrongAttempts,
                        onContinue: onContinue,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final BlockQuestionEntity question;

  const _DifficultyChip({required this.question});

  @override
  Widget build(BuildContext context) {
    final color = _difficultyColor(question.difficulty);
    final label = _difficultyLabel(question.difficulty);
    final baseXp = _baseXpForDifficulty(question.difficulty);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.speed_rounded, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            '$label · $baseXp XP',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _XpCelebrationCard extends StatelessWidget {
  final String? message;
  final List<RewardEntity> rewards;
  final BlockQuestionEntity question;
  final int wrongAttempts;
  final VoidCallback onContinue;

  const _XpCelebrationCard({
    required this.message,
    required this.rewards,
    required this.question,
    required this.wrongAttempts,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final awardedRewards = rewards
        .where((reward) => reward.awarded && reward.xpAwarded > 0)
        .toList();
    final earnedXp = awardedRewards.fold<int>(
      0,
      (total, reward) => total + reward.xpAwarded,
    );
    final blockReward = _blockCompleteReward(awardedRewards);
    final blockBaseXp = _baseXpForDifficulty(question.difficulty);
    final expectedBlockXp = _attemptAdjustedXp(blockBaseXp, wrongAttempts);
    final premiumBonus = blockReward == null
        ? 0
        : math.max(0, blockReward.xpAwarded - expectedBlockXp);
    RewardEntity? levelUpReward;
    for (final reward in awardedRewards) {
      if (reward.leveledUp) {
        levelUpReward = reward;
        break;
      }
    }

    final colors = Theme.of(context).colorScheme;
    final isDark = colors.brightness == Brightness.dark;
    const successColor = Color(0xff2E7D53);
    const successText = Color(0xff205E3E);
    const goldColor = Color(0xffF2C94C);
    final panelSurface = isDark ? const Color(0xff18231E) : colors.surface;
    final headerStart = isDark
        ? successColor.withValues(alpha: 0.28)
        : successColor.withValues(alpha: 0.12);
    final headerEnd = isDark
        ? goldColor.withValues(alpha: 0.16)
        : goldColor.withValues(alpha: 0.22);
    final primaryText = isDark ? const Color(0xffDFF7E7) : successText;
    final secondaryText = isDark
        ? const Color(0xffBDE8CA)
        : successText.withValues(alpha: 0.78);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: panelSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: successColor.withValues(alpha: isDark ? 0.38 : 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.42 : 0.20),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [headerStart, headerEnd],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : Colors.white.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: isDark ? 0.12 : 0.70,
                      ),
                    ),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: goldColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        earnedXp > 0
                            ? 'إجابة صحيحة، ربحت $earnedXp XP'
                            : 'إجابة صحيحة',
                        style: textTheme.titleLarge?.copyWith(
                          color: primaryText,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _feedbackMessage(message, earnedXp),
                        style: textTheme.bodyMedium?.copyWith(
                          color: secondaryText,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (blockReward != null) ...[
                  _PremiumXpBreakdown(
                    baseXp: expectedBlockXp,
                    premiumBonus: premiumBonus,
                  ),
                ],
                if (blockReward != null && blockBaseXp > expectedBlockXp) ...[
                  const SizedBox(height: 12),
                  _PenaltySummary(
                    baseXp: blockBaseXp,
                    awardedXp: expectedBlockXp,
                    wrongAttempts: wrongAttempts,
                  ),
                ],
                if (awardedRewards.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: awardedRewards
                        .map(
                          (reward) => _RewardChip(
                            label: _rewardLabel(reward),
                            xp: reward.xpAwarded,
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (levelUpReward != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: goldColor.withValues(alpha: isDark ? 0.14 : 0.18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: goldColor.withValues(
                          alpha: isDark ? 0.28 : 0.32,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          size: 20,
                          color: Color(0xffB7791F),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'ارتقيت إلى المستوى ${levelUpReward.currentLevelNumber} ${levelUpReward.currentLevelTitle}',
                            style: textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? const Color(0xffF8E7A6)
                                  : const Color(0xff8A5A13),
                              fontWeight: FontWeight.w900,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: successColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'المتابعة',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _feedbackMessage(String? message, int earnedXp) {
    final normalized = message?.trim();
    if (earnedXp > 0) return 'أحسنت، تمت إضافة النقاط إلى تقدمك.';
    if (normalized == null || normalized.isEmpty) {
      return 'تم حل السؤال بنجاح.';
    }
    if (normalized == 'Correct answer') return 'تم حل السؤال بنجاح.';
    return normalized;
  }

  static String _rewardLabel(RewardEntity reward) {
    return switch (reward.eventType) {
      'BLOCK_COMPLETE' => 'إكمال السؤال',
      'LESSON_COMPLETE' => 'إكمال الدرس',
      'CHAPTER_COMPLETE' => 'إكمال الفصل',
      _ => 'مكافأة',
    };
  }
}

class _PremiumXpBreakdown extends StatelessWidget {
  final int baseXp;
  final int premiumBonus;

  const _PremiumXpBreakdown({required this.baseXp, required this.premiumBonus});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = colors.brightness == Brightness.dark;
    final hasPremiumBonus = premiumBonus > 0;
    const successColor = Color(0xff2E7D53);
    const goldColor = Color(0xffF2C94C);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? successColor.withValues(alpha: 0.10)
            : const Color(0xffF7FBF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: successColor.withValues(alpha: isDark ? 0.24 : 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: successColor.withValues(alpha: isDark ? 0.16 : 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.bolt_rounded, color: successColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'مكافأة السؤال',
                  style: textTheme.titleSmall?.copyWith(
                    color: isDark
                        ? const Color(0xffC8F3D5)
                        : const Color(0xff205E3E),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (hasPremiumBonus)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: goldColor.withValues(alpha: isDark ? 0.18 : 0.24),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Premium x1.2',
                    style: textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? const Color(0xffF8E7A6)
                          : const Color(0xff8A5A13),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _XpValueChip(
                label: 'النقاط الأساسية',
                value: '$baseXp XP',
                color: successColor,
              ),
              if (hasPremiumBonus)
                _XpValueChip(
                  label: 'الزيادة',
                  value: '+$premiumBonus XP',
                  color: goldColor,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _XpValueChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _XpValueChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = colors.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.28 : 0.18),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: isDark
                  ? colors.onSurface.withValues(alpha: 0.70)
                  : const Color(0xff205E3E).withValues(alpha: 0.68),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: textTheme.titleSmall?.copyWith(
              color: isDark ? colors.onSurface : const Color(0xff205E3E),
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _PenaltySummary extends StatelessWidget {
  final int baseXp;
  final int awardedXp;
  final int wrongAttempts;

  const _PenaltySummary({
    required this.baseXp,
    required this.awardedXp,
    required this.wrongAttempts,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final lostXp = baseXp > awardedXp ? baseXp - awardedXp : 0;
    final progress = baseXp == 0 ? 1.0 : (awardedXp / baseXp).clamp(0.0, 1.0);
    final color = lostXp > 0
        ? const Color(0xffB7791F)
        : const Color(0xff2E7D53);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                lostXp > 0
                    ? Icons.trending_down_rounded
                    : Icons.verified_rounded,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  lostXp > 0
                      ? 'النقاط بعد الخصم: $awardedXp من $baseXp XP'
                      : 'حصلت على كامل نقاط السؤال: $baseXp XP',
                  style: textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.65),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          if (lostXp > 0) ...[
            const SizedBox(height: 8),
            Text(
              '${_penaltyReason(wrongAttempts)}، خسرت $lostXp XP من مكافأة السؤال.',
              style: textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _penaltyReason(int wrongAttempts) {
  if (wrongAttempts <= 0) return 'بسبب محاولات خاطئة سابقة';
  if (wrongAttempts == 1) return 'بسبب محاولة خاطئة واحدة';
  if (wrongAttempts == 2) return 'بسبب محاولتين خاطئتين';
  return 'بسبب $wrongAttempts محاولات خاطئة';
}

class _RewardChip extends StatelessWidget {
  final String label;
  final int xp;

  const _RewardChip({required this.label, required this.xp});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xff2E7D53).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xff2E7D53).withValues(alpha: 0.16),
        ),
      ),
      child: Text(
        '$label +$xp XP',
        style: TextStyle(
          color: colors.brightness == Brightness.dark
              ? const Color(0xff9AE6B4)
              : const Color(0xff205E3E),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ConfettiBurst extends StatefulWidget {
  final int seed;
  final VoidCallback onCompleted;

  const _ConfettiBurst({
    super.key,
    required this.seed,
    required this.onCompleted,
  });

  @override
  State<_ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<_ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_ConfettiPiece> _pieces;

  @override
  void initState() {
    super.initState();
    final random = math.Random(widget.seed);
    final palette = [
      const Color(0xff2E7D53),
      const Color(0xffF2C94C),
      const Color(0xff2F80ED),
      const Color(0xffD9534F),
      const Color(0xff9B51E0),
    ];

    _pieces = List.generate(58, (index) {
      return _ConfettiPiece(
        angle: -math.pi + random.nextDouble() * math.pi,
        distance: 120 + random.nextDouble() * 210,
        fall: 180 + random.nextDouble() * 260,
        size: 5 + random.nextDouble() * 6,
        spin: (random.nextDouble() * 2 - 1) * math.pi * 3,
        color: palette[random.nextInt(palette.length)],
        isCircle: random.nextBool(),
      );
    });

    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1450),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            widget.onCompleted();
          }
        });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ConfettiPainter(animation: _controller, pieces: _pieces),
      child: const SizedBox.expand(),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final Animation<double> animation;
  final List<_ConfettiPiece> pieces;

  _ConfettiPainter({required this.animation, required this.pieces})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;
    final burst = Curves.easeOutCubic.transform(progress);
    final fall = Curves.easeIn.transform(progress);
    final fadeProgress = ((progress - 0.62) / 0.38).clamp(0.0, 1.0);
    final opacity = 1.0 - Curves.easeIn.transform(fadeProgress);
    final origin = Offset(size.width / 2, size.height / 2 - 86);
    final paint = Paint()..style = PaintingStyle.fill;

    for (final piece in pieces) {
      final dx = math.cos(piece.angle) * piece.distance * burst;
      final dy =
          math.sin(piece.angle) * piece.distance * burst +
          piece.fall * fall * fall;
      final offset = origin + Offset(dx, dy);
      if (offset.dy > size.height + 24) continue;

      paint.color = piece.color.withValues(alpha: opacity);
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.rotate(piece.spin * progress);

      if (piece.isCircle) {
        canvas.drawCircle(Offset.zero, piece.size * 0.48, paint);
      } else {
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: piece.size,
          height: piece.size * 1.8,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(1.5)),
          paint,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.animation != animation || oldDelegate.pieces != pieces;
  }
}

class _ConfettiPiece {
  final double angle;
  final double distance;
  final double fall;
  final double size;
  final double spin;
  final Color color;
  final bool isCircle;

  const _ConfettiPiece({
    required this.angle,
    required this.distance,
    required this.fall,
    required this.size,
    required this.spin,
    required this.color,
    required this.isCircle,
  });
}

int _earnedXp(List<RewardEntity> rewards) {
  return rewards
      .where((reward) => reward.awarded && reward.xpAwarded > 0)
      .fold<int>(0, (total, reward) => total + reward.xpAwarded);
}

RewardEntity? _blockCompleteReward(List<RewardEntity> rewards) {
  for (final reward in rewards) {
    if (reward.eventType == 'BLOCK_COMPLETE' &&
        reward.awarded &&
        reward.xpAwarded > 0) {
      return reward;
    }
  }

  return null;
}

int _baseXpForDifficulty(String difficulty) {
  return switch (difficulty.toUpperCase()) {
    'EASY' => 10,
    'HARD' => 20,
    _ => 15,
  };
}

int _attemptAdjustedXp(int baseXp, int wrongAttempts) {
  final multiplier = math.max(0.30, 1.0 - wrongAttempts * 0.20);
  return math.max(1, (baseXp * multiplier).round());
}

String _difficultyLabel(String difficulty) {
  return switch (difficulty.toUpperCase()) {
    'EASY' => 'سهل',
    'HARD' => 'صعب',
    _ => 'متوسط',
  };
}

Color _difficultyColor(String difficulty) {
  return switch (difficulty.toUpperCase()) {
    'EASY' => const Color(0xff2E7D53),
    'HARD' => const Color(0xffD9534F),
    _ => const Color(0xffB7791F),
  };
}
