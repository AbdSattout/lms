import '../../../organizations/data/models/organization_model.dart';
import '../../domain/entities/recommended_organization_entity.dart';

class RecommendedOrganizationModel extends RecommendedOrganizationEntity {
  const RecommendedOrganizationModel({
    required super.organization,
    required super.score,
    required super.reason,
  });

  factory RecommendedOrganizationModel.fromJson(Map<String, dynamic> json) {
    return RecommendedOrganizationModel(
      organization: OrganizationModel.fromJson(
        json['organization'] as Map<String, dynamic>? ?? {},
      ),
      score: (json['score'] as num?)?.toInt() ?? 0,
      reason: json['reason']?.toString() ?? '',
    );
  }
}
