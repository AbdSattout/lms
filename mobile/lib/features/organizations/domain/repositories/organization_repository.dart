import '../../../courses/domain/entities/course_entity.dart';
import '../entities/organization_entity.dart';
import '../entities/organization_invite_entity.dart';

abstract class OrganizationRepository {
  Future<List<CourseEntity>> getOrganizationCourses(String slug);
  Future<List<OrganizationEntity>> getAllOrganizations();
  Future<List<OrganizationEntity>> getMyOrganizations();
  Future<OrganizationEntity> getOrganizationBySlug(String slug);
  Future<void> joinOrganization(String slug);
  Future<void> leaveOrganization(String slug);
  Future<void> cancelJoinRequest(String slug);
  Future<void> deleteOrganization(String slug);
  Future<List<OrganizationInviteEntity>> getMyInvites();
  Future<OrganizationInviteEntity> getInvitePreviewByToken(String token);
  Future<void> acceptInviteByToken(String token);
  Future<void> acceptInvite({required String slug, required int inviteId});
  Future<void> declineInvite({required String slug, required int inviteId});
}
