import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/api_error_resolver.dart';
import '../../domain/entities/billing_user_entity.dart';
import '../../domain/usecases/create_checkout_session_usecase.dart';
import '../../domain/usecases/create_portal_session_usecase.dart';
import '../../domain/usecases/get_billing_user_usecase.dart';
import '../../domain/usecases/revoke_subscription_usecase.dart';
import 'billing_event.dart';
import 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final GetBillingUserUseCase getBillingUserUseCase;
  final CreateCheckoutSessionUseCase createCheckoutSessionUseCase;
  final CreatePortalSessionUseCase createPortalSessionUseCase;
  final RevokeSubscriptionUseCase revokeSubscriptionUseCase;

  BillingBloc({
    required this.getBillingUserUseCase,
    required this.createCheckoutSessionUseCase,
    required this.createPortalSessionUseCase,
    required this.revokeSubscriptionUseCase,
  }) : super(const BillingState.initial()) {
    on<LoadBillingEvent>(_loadBilling);
    on<StartCheckoutEvent>(_startCheckout);
    on<OpenCustomerPortalEvent>(_openCustomerPortal);
    on<RevokeSubscriptionEvent>(_revokeSubscription);
    on<BillingExternalUrlHandledEvent>(_clearExternalUrls);
    on<BillingCheckoutReturnedEvent>(_checkoutReturned);
  }

  Future<void> _loadBilling(
    LoadBillingEvent event,
    Emitter<BillingState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          isLoading: !event.silent,
          action: BillingAction.none,
          clearError: true,
          clearSuccess: event.silent,
          clearCheckoutUrl: true,
          clearPortalUrl: true,
        ),
      );

      final user = await getBillingUserUseCase();
      final wasPremium = state.user?.isPremium ?? false;

      emit(
        state.copyWith(
          user: user,
          isLoading: false,
          action: BillingAction.none,
          successMessage: event.silent && !wasPremium && user.isPremium
              ? 'شكرا لاشتراكك! تم تفعيل الخطة المميزة.'
              : null,
          clearError: true,
          clearSuccess: !(event.silent && !wasPremium && user.isPremium),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          action: BillingAction.none,
          errorMessage: _message(e),
        ),
      );
    }
  }

  Future<void> _startCheckout(
    StartCheckoutEvent event,
    Emitter<BillingState> emit,
  ) async {
    if (state.isBusy) return;

    try {
      emit(
        state.copyWith(
          action: BillingAction.checkout,
          clearError: true,
          clearSuccess: true,
          clearCheckoutUrl: true,
          clearPortalUrl: true,
        ),
      );

      final session = await createCheckoutSessionUseCase();
      if (session.checkoutUrl.isEmpty) {
        throw const _BillingException('تعذر استلام رابط الدفع من السيرفر');
      }

      emit(
        state.copyWith(
          action: BillingAction.none,
          checkoutUrl: session.checkoutUrl,
          successMessage: 'تم فتح صفحة الدفع. ارجع للتطبيق بعد إكمال العملية.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(action: BillingAction.none, errorMessage: _message(e)),
      );
    }
  }

  Future<void> _openCustomerPortal(
    OpenCustomerPortalEvent event,
    Emitter<BillingState> emit,
  ) async {
    if (state.isBusy) return;

    try {
      emit(
        state.copyWith(
          action: BillingAction.portal,
          clearError: true,
          clearSuccess: true,
          clearCheckoutUrl: true,
          clearPortalUrl: true,
        ),
      );

      final session = await createPortalSessionUseCase();
      if (session.customerPortalUrl.isEmpty) {
        throw const _BillingException('تعذر استلام رابط إدارة الاشتراك');
      }

      emit(
        state.copyWith(
          action: BillingAction.none,
          portalUrl: session.customerPortalUrl,
          successMessage: 'تم فتح بوابة إدارة الاشتراك.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(action: BillingAction.none, errorMessage: _message(e)),
      );
    }
  }

  Future<void> _revokeSubscription(
    RevokeSubscriptionEvent event,
    Emitter<BillingState> emit,
  ) async {
    if (state.isBusy) return;

    try {
      emit(
        state.copyWith(
          action: BillingAction.revoke,
          clearError: true,
          clearSuccess: true,
          clearCheckoutUrl: true,
          clearPortalUrl: true,
        ),
      );

      await revokeSubscriptionUseCase();
      final user = await getBillingUserUseCase();

      emit(
        state.copyWith(
          user: user,
          action: BillingAction.none,
          successMessage: 'تم إلغاء الاشتراك وتحديث خطتك.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(action: BillingAction.none, errorMessage: _message(e)),
      );
    }
  }

  void _clearExternalUrls(
    BillingExternalUrlHandledEvent event,
    Emitter<BillingState> emit,
  ) {
    emit(state.copyWith(clearCheckoutUrl: true, clearPortalUrl: true));
  }

  Future<void> _checkoutReturned(
    BillingCheckoutReturnedEvent event,
    Emitter<BillingState> emit,
  ) async {
    if (!event.completed) {
      emit(
        state.copyWith(
          action: BillingAction.none,
          successMessage: 'لم تكتمل عملية الدفع.',
          clearError: true,
          clearCheckoutUrl: true,
          clearPortalUrl: true,
        ),
      );

      add(const LoadBillingEvent(silent: true));
      return;
    }

    try {
      emit(
        state.copyWith(
          isLoading: true,
          action: BillingAction.none,
          successMessage: 'تمت العودة من Polar. نتحقق من تفعيل الاشتراك...',
          clearError: true,
          clearCheckoutUrl: true,
          clearPortalUrl: true,
        ),
      );

      final user = await _loadUserAfterSuccessfulCheckout();

      emit(
        state.copyWith(
          user: user,
          isLoading: false,
          action: BillingAction.none,
          successMessage: user.isPremium
              ? 'شكرا لاشتراكك! تم تفعيل الخطة المميزة.'
              : 'لم يتم تفعيل الاشتراك بعد. حدّث الصفحة بعد لحظات.',
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          action: BillingAction.none,
          errorMessage: _message(e),
        ),
      );
    }
  }

  Future<BillingUserEntity> _loadUserAfterSuccessfulCheckout() async {
    BillingUserEntity? latestUser;

    for (var attempt = 0; attempt < 4; attempt++) {
      latestUser = await getBillingUserUseCase();
      if (latestUser.isPremium) return latestUser;

      if (attempt < 3) {
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }

    return latestUser ?? await getBillingUserUseCase();
  }

  String _message(Object error) {
    if (error is _BillingException) return error.message;

    final message = resolveApiErrorMessage(error);
    return message.startsWith('Exception: ')
        ? message.replaceFirst('Exception: ', '')
        : message;
  }
}

class _BillingException implements Exception {
  final String message;

  const _BillingException(this.message);
}
