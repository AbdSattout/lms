import '../entities/organization_invite_entity.dart';
import '../repositories/organization_repository.dart';

class GetOrganizationInvitePreviewByTokenUseCase {
  final OrganizationRepository repository;

  GetOrganizationInvitePreviewByTokenUseCase(this.repository);

  Future<OrganizationInviteEntity> call(String token) {
    return repository.getInvitePreviewByToken(token);
  }
}
