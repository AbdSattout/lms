import '../../domain/entities/organization_entity.dart';
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
}