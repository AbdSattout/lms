import '../../../organizations/domain/entities/organization_entity.dart';
import '../repositories/home_repository.dart';

class SearchOrganizationsUseCase {
  final HomeRepository repository;
  SearchOrganizationsUseCase(this.repository);
  Future<List<OrganizationEntity>> call(String query) => repository.searchOrganizations(query);
}