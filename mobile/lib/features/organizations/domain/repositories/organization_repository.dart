import '../entities/organization_entity.dart';

abstract class OrganizationRepository {
  Future<List<OrganizationEntity>> getAllOrganizations();

  Future<OrganizationEntity> getOrganizationBySlug(
      String slug,
      );
}