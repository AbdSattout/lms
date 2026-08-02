import '../repositories/organization_repository.dart';

class JoinOrganizationUseCase {
  final OrganizationRepository repository;
  JoinOrganizationUseCase(this.repository);

  Future<void> call(String slug) {
    return repository.joinOrganization(slug);
  }
}