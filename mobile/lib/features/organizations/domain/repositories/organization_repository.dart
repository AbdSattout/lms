import '../entities/organization_entity.dart';
import '../entities/organization_invite_entity.dart';

abstract class OrganizationRepository {
  Future<List<OrganizationEntity>> getAllOrganizations();
  Future<OrganizationEntity> getOrganizationBySlug(String slug);
  Future<void> joinOrganization(String slug);
  Future<void> leaveOrganization(String slug);
  Future<void> cancelJoinRequest(String slug);
  Future<void> deleteOrganization(String slug);
  Future<List<OrganizationInviteEntity>> getMyInvites();
  Future<void> acceptInvite({required String slug, required int inviteId});
  Future<void> declineInvite({required String slug, required int inviteId});
}
