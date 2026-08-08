import '../entities/billing_session_entity.dart';
import '../repositories/billing_repository.dart';

class CreateCheckoutSessionUseCase {
  final BillingRepository repository;

  CreateCheckoutSessionUseCase(this.repository);

  Future<CheckoutSessionEntity> call() {
    return repository.createCheckoutSession();
  }
}
