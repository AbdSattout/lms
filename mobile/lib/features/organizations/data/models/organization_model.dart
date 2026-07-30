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
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      image: json['image'],
      visibility: OrganizationVisibility.fromApi(json['visibility']),
      ownerName: json['ownerName'],
      membersCount: json['membersCount'] ?? 0,
    );
  }
}