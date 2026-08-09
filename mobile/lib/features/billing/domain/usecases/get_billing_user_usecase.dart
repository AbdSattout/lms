import '../entities/billing_user_entity.dart';
import '../repositories/billing_repository.dart';

class GetBillingUserUseCase {
  final BillingRepository repository;

  GetBillingUserUseCase(this.repository);

  Future<BillingUserEntity> call() {
    return repository.getCurrentUser();
  }
}
