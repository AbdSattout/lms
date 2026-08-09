import '../repositories/organization_repository.dart';

class AcceptOrganizationInviteUseCase {
  final OrganizationRepository repository;

  AcceptOrganizationInviteUseCase(this.repository);

  Future<void> call({required String slug, required int inviteId}) {
    return repository.acceptInvite(slug: slug, inviteId: inviteId);
  }
}
