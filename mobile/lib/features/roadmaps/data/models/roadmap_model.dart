import '../../../organizations/data/models/organization_model.dart';
import '../../domain/entities/roadmap_entity.dart';
import 'roadmap_item_model.dart';

class RoadmapModel extends RoadmapEntity {
  const RoadmapModel({
    required super.id,
    required super.name,
    required super.description,
    super.status,
    super.organization,
    required super.items,
    super.followStatus,
  });

  factory RoadmapModel.fromJson(Map<String, dynamic> json) {
    return RoadmapModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String?,
      organization: json['organization'] != null
          ? OrganizationModel.fromJson(json['organization'] as Map<String, dynamic>)
          : null,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => RoadmapItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      followStatus: json['followStatus'] as String?,
    );
  }
}