import '../../../../core/databases/api/api_consumer.dart';
import '../../../../core/databases/api/end_points.dart';
import '../models/billing_session_models.dart';
import '../models/billing_user_model.dart';

abstract class BillingRemoteDataSource {
  Future<BillingUserModel> getCurrentUser();

  Future<CheckoutSessionModel> createCheckoutSession();

  Future<CustomerPortalSessionModel> createPortalSession();

  Future<void> revokeSubscription();
}

class BillingRemoteDataSourceImpl implements BillingRemoteDataSource {
  final ApiConsumer api;

  BillingRemoteDataSourceImpl(this.api);

  @override
  Future<BillingUserModel> getCurrentUser() async {
    final response = await api.get(EndPoints.currentUser);

    return BillingUserModel.fromJson(response);
  }

  @override
  Future<CheckoutSessionModel> createCheckoutSession() async {
    final response = await api.post(
      EndPoints.billingCheckout,
      data: {'client': 'MOBILE'},
    );

    return CheckoutSessionModel.fromJson(response);
  }

  @override
  Future<CustomerPortalSessionModel> createPortalSession() async {
    final response = await api.post(EndPoints.billingPortal);

    return CustomerPortalSessionModel.fromJson(response);
  }

  @override
  Future<void> revokeSubscription() async {
    await api.post(EndPoints.billingRevoke);
  }
}
