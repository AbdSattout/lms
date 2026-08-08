import '../repositories/billing_repository.dart';

class RevokeSubscriptionUseCase {
  final BillingRepository repository;

  RevokeSubscriptionUseCase(this.repository);

  Future<void> call() {
    return repository.revokeSubscription();
  }
}
