class CheckoutSessionEntity {
  final String checkoutId;
  final String checkoutUrl;

  const CheckoutSessionEntity({
    required this.checkoutId,
    required this.checkoutUrl,
  });
}

class CustomerPortalSessionEntity {
  final String customerPortalUrl;

  const CustomerPortalSessionEntity({required this.customerPortalUrl});
}
