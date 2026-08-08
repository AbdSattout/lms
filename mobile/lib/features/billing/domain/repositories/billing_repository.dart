import '../entities/billing_session_entity.dart';
import '../entities/billing_user_entity.dart';

abstract class BillingRepository {
  Future<BillingUserEntity> getCurrentUser();

  Future<CheckoutSessionEntity> createCheckoutSession();

  Future<CustomerPortalSessionEntity> createPortalSession();

  Future<void> revokeSubscription();
}
