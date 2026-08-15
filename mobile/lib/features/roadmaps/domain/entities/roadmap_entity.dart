import '../../../organizations/domain/entities/organization_entity.dart';
import 'roadmap_item_entity.dart';

class RoadmapEntity {
  final int id;
  final String name;
  final String description;
  final String? status;
  final OrganizationEntity? organization;
  final List<RoadmapItemEntity> items;
  final String? followStatus;

  const RoadmapEntity({
    required this.id,
    required this.name,
    required this.description,
    this.status,
    this.organization,
    this.items = const [],
    this.followStatus,
  });

  bool get isFollowing => followStatus == 'FOLLOWING';
}