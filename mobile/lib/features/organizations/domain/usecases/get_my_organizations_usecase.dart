import '../entities/organization_entity.dart';
import '../repositories/organization_repository.dart';

class GetMyOrganizationsUseCase {
  final OrganizationRepository repository;
  GetMyOrganizationsUseCase(this.repository);
  Future<List<OrganizationEntity>> call() => repository.getMyOrganizations();
}