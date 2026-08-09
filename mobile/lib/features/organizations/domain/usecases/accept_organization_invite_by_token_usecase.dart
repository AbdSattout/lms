import '../repositories/organization_repository.dart';

class AcceptOrganizationInviteByTokenUseCase {
  final OrganizationRepository repository;

  AcceptOrganizationInviteByTokenUseCase(this.repository);

  Future<void> call(String token) {
    return repository.acceptInviteByToken(token);
  }
}
