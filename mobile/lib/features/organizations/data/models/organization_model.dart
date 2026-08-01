import '../../domain/entities/organization_entity.dart';

class OrganizationModel extends OrganizationEntity {
  const OrganizationModel({
    required super.id,
    required super.name,
    required super.slug,
    super.description,
    super.image,
    super.visibility,
    super.ownerName,
    super.membersCount,
    super.viewerJoined,
    super.viewerRole,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    final viewer = json['viewer'] as Map<String, dynamic>?;

    return OrganizationModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      image: json['image'],
      visibility: OrganizationVisibility.fromApi(json['visibility']),
      ownerName: json['ownerName'],
      membersCount: json['membersCount'] ?? 0,
      viewerJoined: viewer?['joined'] ?? false,
      viewerRole: viewer?['role'],
    );
  }
}