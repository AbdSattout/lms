import '../../domain/entities/organization_entity.dart';

class OrganizationMemberModel extends OrganizationMemberEntity {
  const OrganizationMemberModel({
    required super.memberId,
    super.role,
    super.joinedAt,
  });

  factory OrganizationMemberModel.fromJson(Map<String, dynamic> json) {
    return OrganizationMemberModel(
      memberId: json['memberId'] ?? 0,
      role: json['role'],
      joinedAt: json['joinedAt'] != null
          ? DateTime.tryParse(json['joinedAt'])
          : null,
    );
  }
}

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
    super.joinRequestStatus,
    super.inviteStatus,
    super.member,
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
      joinRequestStatus: viewer?['joinRequestStatus'],
      inviteStatus: viewer?['inviteStatus'],
      member: viewer?['member'] != null
          ? OrganizationMemberModel.fromJson(
        viewer!['member'] as Map<String, dynamic>,
      )
          : null,
    );
  }
}