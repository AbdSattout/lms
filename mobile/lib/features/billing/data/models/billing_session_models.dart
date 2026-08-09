import '../../domain/entities/billing_session_entity.dart';

class CheckoutSessionModel extends CheckoutSessionEntity {
  const CheckoutSessionModel({
    required super.checkoutId,
    required super.checkoutUrl,
  });

  factory CheckoutSessionModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};

    return CheckoutSessionModel(
      checkoutId: _readString(map['checkoutId']),
      checkoutUrl: _readString(map['checkoutUrl']),
    );
  }
}

class CustomerPortalSessionModel extends CustomerPortalSessionEntity {
  const CustomerPortalSessionModel({required super.customerPortalUrl});

  factory CustomerPortalSessionModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};

    return CustomerPortalSessionModel(
      customerPortalUrl: _readString(map['customerPortalUrl']),
    );
  }
}

String _readString(Object? value) {
  return value?.toString().trim() ?? '';
}
