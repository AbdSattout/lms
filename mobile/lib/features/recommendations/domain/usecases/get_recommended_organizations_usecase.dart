import '../entities/recommended_organization_entity.dart';
import '../repositories/recommendation_repository.dart';

class GetRecommendedOrganizationsUseCase {
  final RecommendationRepository repository;

  GetRecommendedOrganizationsUseCase(this.repository);

  Future<List<RecommendedOrganizationEntity>> call() {
    return repository.getRecommendedOrganizations();
  }
}
