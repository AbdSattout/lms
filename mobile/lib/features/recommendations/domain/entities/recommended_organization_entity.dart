import '../../../organizations/domain/entities/organization_entity.dart';

class RecommendedOrganizationEntity {
  final OrganizationEntity organization;
  final int score;
  final String reason;

  const RecommendedOrganizationEntity({
    required this.organization,
    required this.score,
    required this.reason,
  });
}
