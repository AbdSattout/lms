import '../repositories/organization_repository.dart';

class CancelJoinRequestUseCase {
  final OrganizationRepository repository;
  CancelJoinRequestUseCase(this.repository);

  Future<void> call(String slug) {
    return repository.cancelJoinRequest(slug);
  }
}