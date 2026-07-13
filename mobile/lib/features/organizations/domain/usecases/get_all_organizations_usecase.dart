import '../entities/organization_entity.dart';
import '../repositories/organization_repository.dart';

class GetAllOrganizationsUseCase {
  final OrganizationRepository repository;

  GetAllOrganizationsUseCase(this.repository);

  Future<List<OrganizationEntity>> call() {
    return repository.getAllOrganizations();
  }
}