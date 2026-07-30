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

    return Scaffold(
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
            return Center(child: Text(state.message, textAlign: TextAlign.center));
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  MarkdownContentView(content: block.content),

                  if (block.question != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Text(
                        block.question!.content,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.5,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    ...List.generate(block.question!.options.length, (i) {
                      final selected = _selectedIndex == i;
                      final wrong = state.lastAnswerCorrect == false && selected;
                      final correct = state.lastAnswerCorrect == true && selected;

                      Color borderColor = Theme.of(context).dividerColor;
                      if (wrong) borderColor = const Color(0xffD9534F);
                      if (correct) borderColor = const Color(0xff2E7D53);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: selected
                              ? borderColor.withOpacity(0.1)
                              : colors.surface,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: state.isSubmitting
                                ? null
                                : () => setState(() => _selectedIndex = i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: borderColor, width: 1.3),
                              ),
                              child: Text(
                                block.question!.options[i],
                                style: TextStyle(color: colors.onSurface),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    if (state.lastAnswerCorrect == false)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          'إجابة خاطئة، حاول مجدداً',
                          style: TextStyle(
                            color: Color(0xffD9534F),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
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
                            : const Text(
                          'تحقق من الإجابة',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
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