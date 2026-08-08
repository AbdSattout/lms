import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/markdown/markdown_content_view.dart';
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
        body: BlocConsumer<BlockContentBloc, BlockContentState>(
          listener: (context, state) {
            if (state is BlockContentLoaded &&
                _activeBlockId != state.block.id) {
              setState(() {
                _activeBlockId = state.block.id;
                _selectedIndex = null;
              });
            }

            if (state is BlockContentLoaded &&
                state.lastAnswerCorrect == true) {
              _progressChanged = true;
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
            if (state is BlockContentLoading || state is BlockContentFinished) {
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

                    if (block.question != null) ...[
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
                                color: colors.primary.withValues(alpha: 0.12),
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
                              child: Text(
                                block.question!.content,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colors.onSurface,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      ...List.generate(block.question!.options.length, (i) {
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
                                  : () => setState(() => _selectedIndex = i),
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
                                        block.question!.options[i],
                                        style: textTheme.bodyLarge?.copyWith(
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
                        _CorrectAnswerCard(
                          message: state.answerResult?.message,
                          rewards: state.answerResult?.rewards ?? const [],
                        ),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                            disabledBackgroundColor: colors.primary.withValues(
                              alpha: 0.4,
                            ),
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
      ),
    );
  }
}

class _CorrectAnswerCard extends StatelessWidget {
  final String? message;
  final List<RewardEntity> rewards;

  const _CorrectAnswerCard({required this.message, required this.rewards});

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
    RewardEntity? levelUpReward;
    for (final reward in awardedRewards) {
      if (reward.leveledUp) {
        levelUpReward = reward;
        break;
      }
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff2E7D53).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xff2E7D53).withValues(alpha: 0.22),
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
                  color: const Color(0xff2E7D53).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xff2E7D53),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  earnedXp > 0
                      ? 'إجابة صحيحة، ربحت $earnedXp XP'
                      : 'إجابة صحيحة',
                  style: textTheme.titleMedium?.copyWith(
                    color: const Color(0xff205E3E),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _feedbackMessage(message, earnedXp),
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xff205E3E),
              height: 1.4,
            ),
          ),
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
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: Color(0xffB7791F),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ارتقيت إلى المستوى ${levelUpReward.currentLevelNumber} ${levelUpReward.currentLevelTitle}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: const Color(0xff8A5A13),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
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
