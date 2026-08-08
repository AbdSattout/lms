abstract class BillingEvent {
  const BillingEvent();
}

class LoadBillingEvent extends BillingEvent {
  final bool silent;

  const LoadBillingEvent({this.silent = false});
}

class StartCheckoutEvent extends BillingEvent {
  const StartCheckoutEvent();
}

class OpenCustomerPortalEvent extends BillingEvent {
  const OpenCustomerPortalEvent();
}

class RevokeSubscriptionEvent extends BillingEvent {
  const RevokeSubscriptionEvent();
}

class BillingExternalUrlHandledEvent extends BillingEvent {
  const BillingExternalUrlHandledEvent();
}

class BillingCheckoutReturnedEvent extends BillingEvent {
  final bool completed;

  const BillingCheckoutReturnedEvent({required this.completed});
}
