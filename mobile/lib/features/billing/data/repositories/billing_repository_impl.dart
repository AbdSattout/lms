import '../../domain/entities/billing_session_entity.dart';
import '../../domain/entities/billing_user_entity.dart';
import '../../domain/repositories/billing_repository.dart';
import '../datasources/billing_remote_datasource.dart';

class BillingRepositoryImpl implements BillingRepository {
  final BillingRemoteDataSource remoteDataSource;

  BillingRepositoryImpl(this.remoteDataSource);

  @override
  Future<BillingUserEntity> getCurrentUser() {
    return remoteDataSource.getCurrentUser();
  }

  @override
  Future<CheckoutSessionEntity> createCheckoutSession() {
    return remoteDataSource.createCheckoutSession();
  }

  @override
  Future<CustomerPortalSessionEntity> createPortalSession() {
    return remoteDataSource.createPortalSession();
  }

  @override
  Future<void> revokeSubscription() {
    return remoteDataSource.revokeSubscription();
  }
}
