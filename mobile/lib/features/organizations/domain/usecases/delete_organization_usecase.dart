import '../repositories/organization_repository.dart';

class DeleteOrganizationUseCase {
  final OrganizationRepository repository;
  DeleteOrganizationUseCase(this.repository);

  Future<void> call(String slug) {
    return repository.deleteOrganization(slug);
  }
}