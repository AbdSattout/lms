import '../repositories/organization_repository.dart';

class LeaveOrganizationUseCase {
  final OrganizationRepository repository;
  LeaveOrganizationUseCase(this.repository);

  Future<void> call(String slug) {
    return repository.leaveOrganization(slug);
  }
}