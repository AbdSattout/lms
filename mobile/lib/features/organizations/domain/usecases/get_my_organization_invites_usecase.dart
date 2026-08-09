import '../entities/organization_invite_entity.dart';
import '../repositories/organization_repository.dart';

class GetMyOrganizationInvitesUseCase {
  final OrganizationRepository repository;

  GetMyOrganizationInvitesUseCase(this.repository);

  Future<List<OrganizationInviteEntity>> call() {
    return repository.getMyInvites();
  }
}
