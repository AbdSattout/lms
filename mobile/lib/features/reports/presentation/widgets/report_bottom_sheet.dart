import 'package:flutter/material.dart';

import '../../../../core/services/injection_container.dart';
import '../../../../core/utils/api_error_resolver.dart';
import '../../domain/entities/report_target.dart';
import '../../domain/usecases/create_report_params.dart';
import '../../domain/usecases/create_report_usecase.dart';

Future<void> showReportBottomSheet(
  BuildContext context,
  ReportTarget target,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => Directionality(
      textDirection: TextDirection.rtl,
      child: _ReportBottomSheet(
        target: target,
        createReport: sl<CreateReportUseCase>(),
      ),
    ),
  );

  if (result == true && context.mounted) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('تم إرسال البلاغ للمراجعة')));
  }
}

class _ReportBottomSheet extends StatefulWidget {
  final ReportTarget target;
  final CreateReportUseCase createReport;

  const _ReportBottomSheet({required this.target, required this.createReport});

  @override
  State<_ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<_ReportBottomSheet> {
  final TextEditingController _detailsController = TextEditingController();
  String? _selectedReason;
  String? _errorMessage;
  bool _isSubmitting = false;

  static const _reasonOptions = [
    _ReportReasonOption(icon: Icons.block_rounded, label: 'محتوى غير مناسب'),
    _ReportReasonOption(
      icon: Icons.sentiment_very_dissatisfied_rounded,
      label: 'إساءة أو تنمر',
    ),
    _ReportReasonOption(
      icon: Icons.warning_amber_rounded,
      label: 'معلومات مضللة',
    ),
    _ReportReasonOption(
      icon: Icons.person_off_rounded,
      label: 'انتحال أو حساب مزيف',
    ),
    _ReportReasonOption(
      icon: Icons.mark_email_unread_rounded,
      label: 'رسائل مزعجة',
    ),
    _ReportReasonOption(icon: Icons.more_horiz_rounded, label: 'سبب آخر'),
  ];

  @override
  void initState() {
    super.initState();
    _detailsController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _reason.trim().isNotEmpty && !_isSubmitting;

  String get _reason {
    final base = _selectedReason?.trim() ?? '';
    final details = _detailsController.text.trim();

    if (base.isEmpty) return details;
    if (details.isEmpty) return base;
    return '$base\n\n$details';
  }

  Future<void> _submit() async {
    final reason = _reason;

    if (reason.isEmpty) {
      setState(() => _errorMessage = 'اختر سبب البلاغ أو اكتب التفاصيل');
      return;
    }

    if (reason.length > 1000) {
      setState(() => _errorMessage = 'سبب البلاغ يجب ألا يتجاوز 1000 حرف');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    try {
      await widget.createReport(
        CreateReportParams(target: widget.target, reason: reason),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = _resolveReportError(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: colors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _iconFor(widget.target.type),
                    color: colors.error,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إبلاغ عن ${widget.target.type.arabicLabel}',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.target.displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'سبب البلاغ',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in _reasonOptions)
                  _ReasonChip(
                    option: option,
                    selected: _selectedReason == option.label,
                    onTap: () {
                      setState(() {
                        _selectedReason = _selectedReason == option.label
                            ? null
                            : option.label;
                        _errorMessage = null;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _detailsController,
              minLines: 3,
              maxLines: 5,
              maxLength: 1000,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'اكتب تفاصيل البلاغ...',
                filled: true,
                fillColor: colors.surfaceContainerHighest.withValues(
                  alpha: 0.45,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colors.primary, width: 1.2),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colors.error.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: colors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: colors.error,
                          fontWeight: FontWeight.w700,
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
              child: ElevatedButton.icon(
                onPressed: _canSubmit ? _submit : null,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.outlined_flag_rounded, size: 19),
                label: Text(
                  _isSubmitting ? 'جارٍ إرسال البلاغ...' : 'إرسال البلاغ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.error,
                  foregroundColor: colors.onError,
                  disabledBackgroundColor: colors.surfaceContainerHighest,
                  disabledForegroundColor: colors.onSurfaceVariant,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _resolveReportError(Object error) {
    final message = resolveApiErrorMessage(error);
    final lower = message.toLowerCase();

    if (lower.contains('duplicate report')) {
      return 'لقد أرسلت بلاغاً لهذا العنصر من قبل';
    }
    if (lower.contains('you cannot report yourself')) {
      return 'لا يمكنك الإبلاغ عن نفسك';
    }
    if (lower.contains('not found')) {
      return 'العنصر الذي تحاول الإبلاغ عنه غير متوفر';
    }
    if (lower.contains('required') || lower.contains('does not match')) {
      return 'تعذر إرسال البلاغ بسبب بيانات غير مكتملة';
    }

    return message;
  }
}

class _ReportReasonOption {
  final IconData icon;
  final String label;

  const _ReportReasonOption({required this.icon, required this.label});
}

class _ReasonChip extends StatelessWidget {
  final _ReportReasonOption option;
  final bool selected;
  final VoidCallback onTap;

  const _ReasonChip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: selected
          ? colors.primary.withValues(alpha: 0.12)
          : colors.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? colors.primary.withValues(alpha: 0.55)
                  : colors.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                option.icon,
                size: 16,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                option.label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _iconFor(ReportTargetType type) {
  return switch (type) {
    ReportTargetType.user => Icons.person_off_rounded,
    ReportTargetType.post => Icons.article_outlined,
    ReportTargetType.comment => Icons.mode_comment_outlined,
    ReportTargetType.course => Icons.menu_book_rounded,
    ReportTargetType.organization => Icons.apartment_rounded,
  };
}
