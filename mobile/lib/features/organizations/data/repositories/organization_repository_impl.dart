import '../../../courses/domain/entities/course_entity.dart';
import '../../domain/entities/organization_entity.dart';
import '../../domain/entities/organization_invite_entity.dart';
import '../../domain/repositories/organization_repository.dart';
import '../datasources/organization_remote_datasource.dart';

class OrganizationRepositoryImpl implements OrganizationRepository {
  final OrganizationRemoteDataSource remote;

  OrganizationRepositoryImpl(this.remote);

  @override
  Future<List<OrganizationEntity>> getAllOrganizations() {
    return remote.getAllOrganizations();
  }

  @override
  Future<OrganizationEntity> getOrganizationBySlug(String slug) {
    return remote.getOrganizationBySlug(slug);
  }

  @override
  Future<void> joinOrganization(String slug) {
    return remote.joinOrganization(slug);
  }

  @override
  Future<void> leaveOrganization(String slug) {
    return remote.leaveOrganization(slug);
  }

  @override
  Future<void> cancelJoinRequest(String slug) {
    return remote.cancelJoinRequest(slug);
  }

  @override
  Future<void> deleteOrganization(String slug) {
    return remote.deleteOrganization(slug);
  }

  @override
  Future<List<CourseEntity>> getOrganizationCourses(String slug) {
    return remote.getOrganizationCourses(slug);
  }

  @override
  Future<List<OrganizationInviteEntity>> getMyInvites() {
    return remote.getMyInvites();
  }

  @override
  Future<void> acceptInviteByToken(String token) {
    return remote.acceptInviteByToken(token);
  }

  @override
  Future<void> acceptInvite({required String slug, required int inviteId}) {
    return remote.acceptInvite(slug: slug, inviteId: inviteId);
  }

  @override
  Future<void> declineInvite({required String slug, required int inviteId}) {
    return remote.declineInvite(slug: slug, inviteId: inviteId);
  }
}
