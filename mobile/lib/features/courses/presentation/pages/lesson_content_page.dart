import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/markdown/markdown_content_view.dart';
import '../../../../core/theme/app_colors.dart';
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
            if (state is BlockContentLoaded && state.lastAnswerCorrect == null) {
              setState(() => _selectedIndex = null);
            }

            if (state is BlockContentFinished) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              Navigator.pop(context, true);
            }

            if (state is BlockContentError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
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
                          color: colors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colors.primary.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: colors.primary.withOpacity(0.12),
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
                        final wrong = state.lastAnswerCorrect == false && selected;
                        final correct = state.lastAnswerCorrect == true && selected;

                        Color borderColor = colors.outlineVariant;
                        Color bgColor = colors.surface;
                        IconData? leadingIcon;

                        if (wrong) {
                          borderColor = const Color(0xffD9534F);
                          bgColor = const Color(0xffD9534F).withOpacity(0.05);
                          leadingIcon = Icons.close_rounded;
                        }
                        if (correct) {
                          borderColor = const Color(0xff2E7D53);
                          bgColor = const Color(0xff2E7D53).withOpacity(0.05);
                          leadingIcon = Icons.check_rounded;
                        }
                        if (selected && !wrong && !correct) {
                          borderColor = colors.primary;
                          bgColor = colors.primary.withOpacity(0.05);
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: state.isSubmitting
                                  ? null
                                  : () => setState(() => _selectedIndex = i),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
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
                                        padding: const EdgeInsets.only(left: 10),
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

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                            disabledBackgroundColor: colors.primary.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: (_selectedIndex == null || state.isSubmitting)
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
                            'تحقق من الإجابة',
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