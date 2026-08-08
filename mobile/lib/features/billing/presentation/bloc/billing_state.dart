import '../../domain/entities/billing_user_entity.dart';

enum BillingAction { none, checkout, portal, revoke }

class BillingState {
  final BillingUserEntity? user;
  final bool isLoading;
  final BillingAction action;
  final String? errorMessage;
  final String? successMessage;
  final String? checkoutUrl;
  final String? portalUrl;

  const BillingState({
    required this.user,
    required this.isLoading,
    required this.action,
    required this.errorMessage,
    required this.successMessage,
    required this.checkoutUrl,
    required this.portalUrl,
  });

  const BillingState.initial()
    : user = null,
      isLoading = false,
      action = BillingAction.none,
      errorMessage = null,
      successMessage = null,
      checkoutUrl = null,
      portalUrl = null;

  bool get isBusy => isLoading || action != BillingAction.none;

  BillingState copyWith({
    BillingUserEntity? user,
    bool? isLoading,
    BillingAction? action,
    String? errorMessage,
    String? successMessage,
    String? checkoutUrl,
    String? portalUrl,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearCheckoutUrl = false,
    bool clearPortalUrl = false,
  }) {
    return BillingState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      action: action ?? this.action,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
      checkoutUrl: clearCheckoutUrl ? null : checkoutUrl ?? this.checkoutUrl,
      portalUrl: clearPortalUrl ? null : portalUrl ?? this.portalUrl,
    );
  }
}
