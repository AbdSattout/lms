import '../repositories/organization_repository.dart';

class DeclineOrganizationInviteUseCase {
  final OrganizationRepository repository;

  DeclineOrganizationInviteUseCase(this.repository);

  Future<void> call({required String slug, required int inviteId}) {
    return repository.declineInvite(slug: slug, inviteId: inviteId);
  }
}
