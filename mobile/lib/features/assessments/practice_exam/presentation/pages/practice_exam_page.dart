import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/markdown/markdown_content_view.dart';
import '../../../../../core/services/injection_container.dart';
import '../../../core/presentation/widgets/quiz_option_tile.dart';
import '../bloc/practice_exam_bloc.dart';
import '../bloc/practice_exam_event.dart';
import '../bloc/practice_exam_state.dart';
import 'practice_exam_result_page.dart';

class PracticeExamPage extends StatefulWidget {
  final int courseId;
  final int examId;
  const PracticeExamPage({super.key, required this.courseId, required this.examId});

  @override
  State<PracticeExamPage> createState() => _PracticeExamPageState();
}

class _PracticeExamPageState extends State<PracticeExamPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _isExpired = false;
  bool _autoSubmitted = false;

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer(DateTime? expiresAt, DateTime? serverTime) {
    if (expiresAt == null || serverTime == null) return;

    final offset = serverTime.difference(DateTime.now());

    void tick() {
      final effectiveNow = DateTime.now().add(offset);
      final remaining = expiresAt.difference(effectiveNow);

      if (!mounted) return;

      if (remaining.isNegative || remaining == Duration.zero) {
        setState(() {
          _remaining = Duration.zero;
          _isExpired = true;
        });
        _timer?.cancel();

        if (!_autoSubmitted) {
          _autoSubmitted = true;
          _submitExam();
        }
        return;
      }

      setState(() => _remaining = remaining);
    }

    tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  void _submitExam() {
    context.read<PracticeExamBloc>().add(SubmitPracticeExamRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PracticeExamBloc>()
        ..add(LoadPracticeExamDetails(courseId: widget.courseId, examId: widget.examId)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: const Text('الامتحان التدريبي')),
          body: BlocConsumer<PracticeExamBloc, PracticeExamState>(
            listener: (context, state) {
              if (state is PracticeExamDetailsReady && _timer == null) {
                _startTimer(state.exam.expiresAt, state.exam.serverTime);
              }
              if (state is PracticeExamCompleted) {
                _timer?.cancel();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => PracticeExamResultPage(result: state.result)),
                );
              }
              if (state is PracticeExamFailed) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              return switch (state) {
                PracticeExamInitial() || PracticeExamDetailsLoading() => const Center(child: CircularProgressIndicator()),
                PracticeExamDetailsReady() => _buildExam(context, state),
                PracticeExamSubmitting() => _buildSubmitting(context),
                PracticeExamCompleted() => const SizedBox(),
                PracticeExamFailed() => _buildError(context, state.message),
                _ => const SizedBox(),
              };
            },
          ),
        ),
      ),
    );
  }

  Widget _buildExam(BuildContext context, PracticeExamDetailsReady state) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        _buildTimerHeader(context),
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
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('سؤال ${index + 1} من ${state.totalQuestions}', style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  MarkdownContentView(content: question.content),
                  const SizedBox(height: 24),
                  ...question.options.asMap().entries.map((entry) {
                    return QuizOptionTile(
                      option: entry.value,
                      index: entry.key,
                      isSelected: selected == entry.key && !_isExpired,
                      onTap: _isExpired
                          ? null
                          : () {
                        context.read<PracticeExamBloc>().add(
                          PracticeExamAnswerSelected(questionId: question.id, answerIndex: entry.key),
                        );
                      },
                    );
                  }),
                ]),
              );
            },
          ),
        ),
        _buildBottomNavigation(context, state),
      ],
    );
  }

  Widget _buildTimerHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final minutes = _remaining.inMinutes;
    final seconds = _remaining.inSeconds % 60;
    final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final isUrgent = _remaining.inMinutes < 5 && !_isExpired;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: isUrgent ? const Color(0xffD9534F).withOpacity(0.1) : colors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isExpired ? Icons.timer_off_rounded : Icons.timer_rounded,
            size: 20,
            color: isUrgent || _isExpired ? const Color(0xffD9534F) : colors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            _isExpired ? 'انتهى الوقت' : timeStr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isUrgent || _isExpired ? const Color(0xffD9534F) : colors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context, PracticeExamDetailsReady state) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(color: colors.surface, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))]),
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
                onPressed: state.selectedAnswers.containsKey(state.exam.questions[_currentIndex].id) && !_isExpired
                    ? () => _pageController.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut)
                    : null,
                style: ElevatedButton.styleFrom(backgroundColor: colors.primary, foregroundColor: colors.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('التالي'),
              )
            else
              ElevatedButton.icon(
                onPressed: (state.allAnswered || _isExpired)
                    ? () => _showSubmitConfirmation(context)
                    : null,
                style: ElevatedButton.styleFrom(backgroundColor: colors.primary, foregroundColor: colors.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
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
          title: const Text('إنهاء الامتحان'),
          content: const Text('هل أنت متأكد من إنهاء الامتحان وإرسال إجاباتك؟'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _submitExam();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
              child: const Text('إرسال'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitting(BuildContext context) {
    return const Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('جاري تصحيح الإجابات...'),
      ]),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('العودة')),
        ]),
      ),
    );
  }
}