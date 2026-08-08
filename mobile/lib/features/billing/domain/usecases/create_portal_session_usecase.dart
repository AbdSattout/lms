import '../entities/billing_session_entity.dart';
import '../repositories/billing_repository.dart';

class CreatePortalSessionUseCase {
  final BillingRepository repository;

  CreatePortalSessionUseCase(this.repository);

  Future<CustomerPortalSessionEntity> call() {
    return repository.createPortalSession();
  }
}
