import '../entities/organization_entity.dart';

abstract class OrganizationRepository {
  Future<List<OrganizationEntity>> getAllOrganizations();

  Future<OrganizationEntity> getOrganizationBySlug(String slug);
  Future<void> joinOrganization(String slug);
  Future<void> leaveOrganization(String slug);
  Future<void> cancelJoinRequest(String slug);
}