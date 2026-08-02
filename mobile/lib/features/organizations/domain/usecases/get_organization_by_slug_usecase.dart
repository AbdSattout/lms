import '../entities/organization_entity.dart';
import '../repositories/organization_repository.dart';

class GetOrganizationBySlugUseCase {
  final OrganizationRepository repository;
  GetOrganizationBySlugUseCase(this.repository);

  Future<OrganizationEntity> call(String slug) {
    return repository.getOrganizationBySlug(slug);
  }
}