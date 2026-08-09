import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/external_url_launcher.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/billing_user_entity.dart';
import '../bloc/billing_bloc.dart';
import '../bloc/billing_event.dart';
import '../bloc/billing_state.dart';

class BillingPage extends StatefulWidget {
  const BillingPage({super.key});

  @override
  State<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> with WidgetsBindingObserver {
  late final ExternalUrlLauncher _externalUrlLauncher;
  StreamSubscription<Uri>? _billingDeepLinkSubscription;

  @override
  void initState() {
    super.initState();
    _externalUrlLauncher = sl<ExternalUrlLauncher>();
    _billingDeepLinkSubscription = _externalUrlLauncher.billingDeepLinks.listen(
      _handleBillingDeepLink,
    );
    unawaited(_readInitialBillingDeepLink());
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_billingDeepLinkSubscription?.cancel());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<BillingBloc>().add(const LoadBillingEvent(silent: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<BillingBloc, BillingState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage ||
            previous.successMessage != current.successMessage ||
            previous.resultDialog != current.resultDialog ||
            previous.checkoutUrl != current.checkoutUrl ||
            previous.portalUrl != current.portalUrl,
        listener: _listen,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: const Text('الخطط والمدفوعات'),
              centerTitle: true,
              actions: [
                IconButton(
                  tooltip: 'تحديث',
                  onPressed: state.isBusy
                      ? null
                      : () => context.read<BillingBloc>().add(
                          const LoadBillingEvent(),
                        ),
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  void _listen(BuildContext context, BillingState state) {
    if (state.errorMessage != null) {
      context.read<BillingBloc>().add(const BillingNoticeShownEvent());
      unawaited(
        _showBillingNoticeDialog(
          context,
          title: 'تعذر تنفيذ العملية',
          message: state.errorMessage!,
          icon: Icons.error_outline_rounded,
          accent: Colors.red,
        ),
      );
    }

    if (state.successMessage != null) {
      context.read<BillingBloc>().add(const BillingNoticeShownEvent());
      unawaited(
        _showBillingNoticeDialog(
          context,
          title: 'تم التحديث',
          message: state.successMessage!,
          icon: Icons.check_circle_rounded,
          accent: Colors.green,
        ),
      );
    }

    final resultDialog = state.resultDialog;
    if (resultDialog != null) {
      context.read<BillingBloc>().add(const BillingResultDialogShownEvent());
      unawaited(_showBillingResultDialog(context, resultDialog));
    }

    final externalUrl = state.checkoutUrl ?? state.portalUrl;
    if (externalUrl != null) {
      unawaited(_openExternalUrl(context, externalUrl));
    }
  }

  Future<void> _showBillingResultDialog(
    BuildContext context,
    BillingResultDialog result,
  ) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: _BillingResultDialogCard(
            type: result.type,
            onClose: () => Navigator.of(dialogContext).pop(),
          ),
        );
      },
    );
  }

  Future<void> _showBillingNoticeDialog(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color accent,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: _BillingNoticeDialogCard(
            title: title,
            message: message,
            icon: icon,
            accent: accent,
            onClose: () => Navigator.of(dialogContext).pop(),
          ),
        );
      },
    );
  }

  Future<void> _openExternalUrl(BuildContext context, String url) async {
    try {
      await _externalUrlLauncher.open(url);
    } catch (error) {
      if (!context.mounted) return;

      final message = error is PlatformException
          ? error.message ?? 'تعذر فتح الرابط'
          : 'تعذر فتح الرابط';

      unawaited(
        _showBillingNoticeDialog(
          context,
          title: 'تعذر فتح الرابط',
          message: message,
          icon: Icons.link_off_rounded,
          accent: Colors.red,
        ),
      );
    } finally {
      if (context.mounted) {
        context.read<BillingBloc>().add(const BillingExternalUrlHandledEvent());
      }
    }
  }

  Future<void> _readInitialBillingDeepLink() async {
    final uri = await _externalUrlLauncher.takeInitialBillingDeepLink();
    if (uri != null && mounted) {
      _handleBillingDeepLink(uri);
    }
  }

  void _handleBillingDeepLink(Uri uri) {
    unawaited(_externalUrlLauncher.clearInitialBillingDeepLink());

    final action = uri.pathSegments.isEmpty
        ? uri.queryParameters['status']?.toLowerCase()
        : uri.pathSegments.first.toLowerCase();

    if (action == 'success' || action == 'completed' || action == 'complete') {
      context.read<BillingBloc>().add(
        const BillingCheckoutReturnedEvent(completed: true),
      );
      return;
    }

    if (action == 'cancel' || action == 'canceled' || action == 'cancelled') {
      context.read<BillingBloc>().add(
        const BillingCheckoutReturnedEvent(completed: false),
      );
    }
  }

  Widget _buildBody(BuildContext context, BillingState state) {
    final user = state.user;

    if (state.isLoading && user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (user == null) {
      return _BillingErrorView(
        message: state.errorMessage ?? 'تعذر تحميل بيانات الخطة',
        onRetry: () =>
            context.read<BillingBloc>().add(const LoadBillingEvent()),
      );
    }

    final isPremium = user.isPremium;
    final isRevoked = isPremium && user.isSubscriptionRevoked;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BillingStatusCard(user: user, state: state),
            const SizedBox(height: 18),
            _PlanCard(
              title: 'الخطة المجانية',
              subtitle: 'مناسبة لتجربة المنصة واستكشاف الميزات الأساسية.',
              price: 'مجاناً',
              priceSuffix: '',
              icon: Icons.school_outlined,
              accentColor: AppColors.darkSoft,
              isDimmed: isPremium,
              badge: isPremium ? 'غير نشطة حاليا' : 'خطتك الحالية',
              action: _DisabledPlanButton(
                text: isPremium ? 'غير نشطة حاليا' : 'خطتك الحالية',
                isActiveCurrent: !isPremium,
              ),
              features: const [
                _PlanFeature(
                  Icons.bolt_rounded,
                  '10 استخدامات للذكاء الاصطناعي يوميا',
                ),
                _PlanFeature(
                  Icons.quiz_outlined,
                  '2 اختبار ذكاء اصطناعي أسبوعيا',
                ),
                _PlanFeature(
                  Icons.menu_book_rounded,
                  '2 تسجيل في الدورات أسبوعيا',
                ),
                _PlanFeature(Icons.route_rounded, 'متابعة خريطة تعليمية واحدة'),
                _PlanFeature(
                  Icons.shuffle_rounded,
                  'اختبار عشوائي واحد لكل دورة كل 7 أيام',
                ),
                _PlanFeature(Icons.business_rounded, 'منظمة واحدة'),
                _PlanFeature(Icons.library_books_rounded, '3 دورات في المنظمة'),
                _PlanFeature(Icons.storage_rounded, '100 MB مساحة تخزين'),
                _PlanFeature(Icons.star_rounded, '1.00x مضاعف نقاط الخبرة'),
              ],
            ),
            const SizedBox(height: 18),
            _PlanCard(
              title: 'الخطة المميزة',
              subtitle: 'للمتعلمين النشطين وصناع المحتوى وأصحاب المنظمات.',
              price: r'$5.00',
              priceSuffix: '/ شهريا',
              icon: Icons.workspace_premium_rounded,
              accentColor: isPremium
                  ? Colors.green
                  : isRevoked
                  ? Colors.red
                  : const Color(0xffF59E0B),
              badge: isPremium
                  ? 'مفعلة'
                  : isRevoked
                  ? 'ملغاة'
                  : 'موصى بها',
              action: _PremiumPlanActions(
                state: state,
                isPremium: isPremium,
                onCheckout: () =>
                    context.read<BillingBloc>().add(const StartCheckoutEvent()),
                onPortal: () => context.read<BillingBloc>().add(
                  const OpenCustomerPortalEvent(),
                ),
                onRevoke: () => _confirmRevoke(context),
              ),
              features: const [
                _PlanFeature(
                  Icons.bolt_rounded,
                  'استخدام غير محدود للذكاء الاصطناعي',
                ),
                _PlanFeature(
                  Icons.quiz_outlined,
                  'إنشاء غير محدود لاختبارات الذكاء الاصطناعي',
                ),
                _PlanFeature(
                  Icons.menu_book_rounded,
                  'تسجيل غير محدود في الدورات',
                ),
                _PlanFeature(
                  Icons.route_rounded,
                  'متابعة غير محدودة للخرائط التعليمية',
                ),
                _PlanFeature(
                  Icons.shuffle_rounded,
                  'اختبارات عشوائية غير محدودة لكل دورة',
                ),
                _PlanFeature(Icons.business_rounded, 'منظمات غير محدودة'),
                _PlanFeature(
                  Icons.library_books_rounded,
                  'دورات غير محدودة في المنظمة',
                ),
                _PlanFeature(Icons.storage_rounded, 'مساحة تخزين غير محدودة'),
                _PlanFeature(Icons.star_rounded, '1.20x مضاعف نقاط الخبرة'),
              ],
            ),
            const SizedBox(height: 92),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRevoke(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            icon: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 30,
              ),
            ),
            title: const Text('تأكيد إلغاء الاشتراك'),
            content: const Text(
              'سيتم إلغاء الخطة المميزة فورا ولن يتم استرداد المبلغ المدفوع. هل تريد المتابعة؟',
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('تراجع'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('إلغاء الاشتراك'),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true && context.mounted) {
      context.read<BillingBloc>().add(const RevokeSubscriptionEvent());
    }
  }
}

class _BillingResultDialogCard extends StatelessWidget {
  final BillingResultDialogType type;
  final VoidCallback onClose;

  const _BillingResultDialogCard({required this.type, required this.onClose});

  bool get isSuccess => type == BillingResultDialogType.purchaseSuccess;
  bool get isRevoked => type == BillingResultDialogType.subscriptionRevoked;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = isSuccess
        ? Colors.green
        : isRevoked
        ? const Color(0xff6366F1)
        : const Color(0xffF59E0B);
    final accentSoft = accent.withValues(alpha: 0.11);
    final icon = isSuccess
        ? Icons.check_circle_rounded
        : isRevoked
        ? Icons.favorite_border_rounded
        : Icons.pause_circle_filled_rounded;
    final title = isSuccess
        ? 'شكرا لشرائك!'
        : isRevoked
        ? 'نأسف لمغادرتك'
        : 'لم تكتمل عملية الدفع';
    final body = isSuccess
        ? 'تم تفعيل الخطة المميزة على حسابك. استمتع بكل المزايا الجديدة.'
        : isRevoked
        ? 'تم إلغاء الاشتراك وتحديث خطتك. سنكون سعداء بعودتك إلى الخطة المميزة في أي وقت.'
        : 'تم إيقاف العملية قبل إتمام الشراء. يمكنك الاشتراك في أي وقت.';
    final badgeText = isSuccess
        ? 'الخطة المميزة مفعلة الآن'
        : isRevoked
        ? 'تمت العودة إلى الخطة المجانية'
        : 'لم يتم خصم أي مبلغ';
    final buttonText = isSuccess
        ? 'رائع'
        : isRevoked
        ? 'شكرا'
        : 'حسنا';

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 390),
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: accent.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 34,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: accentSoft,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accent, size: 44),
                ),
                if (isSuccess || isRevoked)
                  Positioned(
                    top: -4,
                    right: -2,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xffF59E0B).withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xffF59E0B),
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 14,
                height: 1.55,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: accentSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withValues(alpha: 0.18)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSuccess
                        ? Icons.workspace_premium_rounded
                        : isRevoked
                        ? Icons.check_rounded
                        : Icons.shield_outlined,
                    color: accent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      badgeText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.onSurface,
                  foregroundColor: colors.surface,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
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

class _BillingNoticeDialogCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color accent;
  final VoidCallback onClose;

  const _BillingNoticeDialogCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.accent,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 370),
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: accent.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accent, size: 38),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 14,
                height: 1.55,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.onSurface,
                  foregroundColor: colors.surface,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'حسنا',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillingStatusCard extends StatelessWidget {
  final BillingUserEntity user;
  final BillingState state;

  const _BillingStatusCard({required this.user, required this.state});

  @override
  Widget build(BuildContext context) {
    final isPremium = user.isPremium;
    final isRevoked = isPremium && user.isSubscriptionRevoked;
    final subscription = user.subscription;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    final useAccentSurface = isPremium || isRevoked;
    final accent = isRevoked
        ? Colors.red
        : isPremium
        ? Colors.green
        : AppColors.primary;
    final foreground = useAccentSurface ? Colors.white : colors.onSurface;
    final muted = useAccentSurface
        ? Colors.white.withValues(alpha: 0.72)
        : colors.onSurfaceVariant;
    final cardColor = useAccentSurface
        ? null
        : isDark
        ? Theme.of(context).cardColor
        : AppColors.primaryLight;
    final panelColor = useAccentSurface
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.white.withValues(alpha: isDark ? 0.06 : 0.72);
    final panelBorderColor = useAccentSurface
        ? Colors.white.withValues(alpha: 0.16)
        : Colors.white.withValues(alpha: isDark ? 0.08 : 0.34);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        gradient: useAccentSurface
            ? LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  accent,
                  isRevoked ? const Color(0xff991B1B) : const Color(0xff10B981),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: useAccentSurface
              ? Colors.white.withValues(alpha: 0.12)
              : accent.withValues(alpha: isDark ? 0.18 : 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.12 : 0.14),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: panelColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: panelBorderColor),
                ),
                child: Icon(
                  isPremium
                      ? Icons.workspace_premium_rounded
                      : isRevoked
                      ? Icons.cancel_outlined
                      : Icons.school_outlined,
                  color: useAccentSurface ? Colors.white : accent,
                  size: 29,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'خطتك الحالية',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _planName(user),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              _PlanHeaderBadge(
                text: isRevoked
                    ? 'Revoked'
                    : isPremium
                    ? 'Premium'
                    : 'Free',
                accent: accent,
                isOnAccentSurface: useAccentSurface,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: panelColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: panelBorderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _StatusMetric(
                    icon: Icons.verified_user_outlined,
                    title: 'الحالة',
                    value: _subscriptionStatus(user, subscription),
                    isInverted: useAccentSurface,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatusMetric(
                    icon: Icons.event_available_rounded,
                    title: 'المدة',
                    value: _periodLabel(isPremium ? subscription : null),
                    isInverted: useAccentSurface,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatusMetric(
                    icon: Icons.payments_outlined,
                    title: 'الدفع',
                    value: isRevoked
                        ? 'ملغى'
                        : isPremium
                        ? 'مفعل'
                        : 'غير مفعل',
                    isInverted: useAccentSurface,
                  ),
                ),
              ],
            ),
          ),
          if (state.isLoading) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              minHeight: 3,
              borderRadius: BorderRadius.circular(99),
              backgroundColor: Colors.white.withValues(alpha: 0.20),
              color: useAccentSurface ? Colors.white : AppColors.primary,
            ),
          ],
        ],
      ),
    );
  }

  String _planName(BillingUserEntity user) {
    final name = user.plan?.name.trim();
    final planIsPremium = user.plan?.premium ?? false;
    if (name != null && name.isNotEmpty && (user.isPremium || !planIsPremium)) {
      return name;
    }
    return user.isPremium ? 'الخطة المميزة' : 'الخطة المجانية';
  }

  String _subscriptionStatus(
    BillingUserEntity user,
    BillingSubscriptionEntity? subscription,
  ) {
    if (!user.isPremium) return 'مجانية';
    if (subscription?.isRevokedOrCanceled ?? false) return 'ملغاة';
    if (subscription == null) return 'مميزة';
    if (subscription.cancelAtPeriodEnd) return 'ستنتهي';

    final status = subscription.status.trim();
    if (status.isEmpty) return 'نشطة';

    return switch (status.toLowerCase()) {
      'active' => 'نشطة',
      'trialing' => 'تجريبية',
      'canceled' || 'cancelled' => 'ملغاة',
      'past_due' => 'متأخرة',
      _ => status,
    };
  }

  String _periodLabel(BillingSubscriptionEntity? subscription) {
    if (subscription?.isRevokedOrCanceled ?? false) return 'تم الإلغاء';

    if (subscription?.daysLeft != null) {
      final days = subscription!.daysLeft!;
      if (days <= 0) return 'تنتهي اليوم';
      return '$days يوم متبقي';
    }

    return 'مستمرة';
  }
}

class _StatusMetric extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isInverted;

  const _StatusMetric({
    required this.icon,
    required this.title,
    required this.value,
    required this.isInverted,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = isInverted ? Colors.white : colors.onSurface;
    final muted = isInverted ? Colors.white70 : colors.onSurfaceVariant;

    return SizedBox(
      width: 96,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: muted),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanHeaderBadge extends StatelessWidget {
  final String text;
  final Color accent;
  final bool isOnAccentSurface;

  const _PlanHeaderBadge({
    required this.text,
    required this.accent,
    required this.isOnAccentSurface,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = isOnAccentSurface ? Colors.white : accent;
    final background = isOnAccentSurface
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.72);
    final borderColor = isOnAccentSurface
        ? Colors.white.withValues(alpha: 0.20)
        : Colors.white.withValues(alpha: 0.36);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String priceSuffix;
  final IconData icon;
  final Color accentColor;
  final String badge;
  final Widget action;
  final List<_PlanFeature> features;
  final bool isDimmed;

  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.priceSuffix,
    required this.icon,
    required this.accentColor,
    required this.badge,
    required this.action,
    required this.features,
    this.isDimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDimmed ? 0.70 : 1,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accentColor.withValues(alpha: 0.22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: accentColor, size: 28),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusPill(text: badge, foreground: accentColor),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(height: 1.45),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (priceSuffix.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      priceSuffix,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            action,
            const SizedBox(height: 18),
            Divider(color: Theme.of(context).dividerColor),
            const SizedBox(height: 8),
            ...features.map(
              (feature) => _FeatureRow(feature: feature, color: accentColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumPlanActions extends StatelessWidget {
  final BillingState state;
  final bool isPremium;
  final VoidCallback onCheckout;
  final VoidCallback onPortal;
  final VoidCallback onRevoke;

  const _PremiumPlanActions({
    required this.state,
    required this.isPremium,
    required this.onCheckout,
    required this.onPortal,
    required this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPremium) {
      return _PrimaryPlanButton(
        text: 'اشترك في المميزة',
        icon: Icons.lock_open_rounded,
        color: const Color(0xffF59E0B),
        isLoading: state.action == BillingAction.checkout,
        onPressed: state.isBusy ? null : onCheckout,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PrimaryPlanButton(
          text: 'إدارة الاشتراك',
          icon: Icons.settings_rounded,
          color: Colors.green,
          isLoading: state.action == BillingAction.portal,
          onPressed: state.isBusy ? null : onPortal,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 52,
          child: OutlinedButton.icon(
            onPressed: state.isBusy ? null : onRevoke,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red.withValues(alpha: 0.30)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: state.action == BillingAction.revoke
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cancel_outlined, size: 20),
            label: const Text(
              'إلغاء الاشتراك',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryPlanButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _PrimaryPlanButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withValues(alpha: 0.45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.4,
                ),
              )
            : Icon(icon, size: 20),
        label: Text(
          isLoading ? 'جاري التحميل...' : text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _DisabledPlanButton extends StatelessWidget {
  final String text;
  final bool isActiveCurrent;

  const _DisabledPlanButton({required this.text, this.isActiveCurrent = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isActiveCurrent
        ? (isDark ? const Color(0xff86EFAC) : const Color(0xff238A5A))
        : colors.onSurfaceVariant;

    return Container(
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActiveCurrent
            ? accent.withValues(alpha: isDark ? 0.13 : 0.10)
            : Theme.of(context).dividerColor.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActiveCurrent
              ? accent.withValues(alpha: isDark ? 0.30 : 0.22)
              : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActiveCurrent) ...[
            Icon(Icons.check_circle_rounded, color: accent, size: 20),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isActiveCurrent
                    ? accent
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final _PlanFeature feature;
  final Color color;

  const _FeatureRow({required this.feature, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: color, size: 17),
          ),
          const SizedBox(width: 10),
          Icon(feature.icon, color: color.withValues(alpha: 0.88), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final Color foreground;

  const _StatusPill({required this.text, required this.foreground});

  @override
  Widget build(BuildContext context) {
    final isCurrentPlan = text == 'خطتك الحالية';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pillColor = isCurrentPlan
        ? (isDark ? const Color(0xff86EFAC) : const Color(0xff238A5A))
        : foreground;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isCurrentPlan
            ? pillColor.withValues(alpha: isDark ? 0.13 : 0.10)
            : Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: pillColor.withValues(alpha: isCurrentPlan ? 0.24 : 0.16),
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: pillColor,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PlanFeature {
  final IconData icon;
  final String text;

  const _PlanFeature(this.icon, this.text);
}

class _BillingErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _BillingErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 42,
              ),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
