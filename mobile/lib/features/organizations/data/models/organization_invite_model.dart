import '../../domain/entities/organization_entity.dart';
import '../../domain/entities/organization_invite_entity.dart';

class OrganizationInviteOrganizationModel
    extends OrganizationInviteOrganizationEntity {
  const OrganizationInviteOrganizationModel({
    required super.id,
    required super.name,
    required super.slug,
    super.description,
    super.imageUrl,
    super.visibility,
    super.ownerName,
  });

  factory OrganizationInviteOrganizationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final owner = json['owner'] as Map<String, dynamic>?;

    return OrganizationInviteOrganizationModel(
      id: _readInt(json['id']),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      visibility: OrganizationVisibility.fromApi(
        json['visibility']?.toString(),
      ),
      ownerName: owner?['name']?.toString(),
    );
  }
}

class OrganizationInviteOverviewModel extends OrganizationInviteOverviewEntity {
  const OrganizationInviteOverviewModel({
    super.membersCount,
    super.adminsCount,
    super.studentsCount,
    super.coursesCount,
    super.publishedCoursesCount,
  });

  factory OrganizationInviteOverviewModel.fromJson(Map<String, dynamic> json) {
    return OrganizationInviteOverviewModel(
      membersCount: _readInt(json['membersCount']),
      adminsCount: _readInt(json['adminsCount']),
      studentsCount: _readInt(json['studentsCount']),
      coursesCount: _readInt(json['coursesCount']),
      publishedCoursesCount: _readInt(json['publishedCoursesCount']),
    );
  }
}

class OrganizationInviteModel extends OrganizationInviteEntity {
  const OrganizationInviteModel({
    required super.id,
    super.userId,
    super.userName,
    required super.role,
    required super.status,
    super.token,
    required super.organization,
    super.overview,
    super.invitedByName,
    super.expiresAt,
    super.maxUses,
    super.usedCount,
    super.alreadyJoined,
  });

  factory OrganizationInviteModel.fromJson(Map<String, dynamic> json) {
    final organizationJson =
        json['organization'] as Map<String, dynamic>? ?? const {};
    final overviewJson = json['overview'] as Map<String, dynamic>?;

    return OrganizationInviteModel(
      id: _readInt(json['id']),
      userId: _readNullableInt(json['userId']),
      userName: json['userName']?.toString(),
      role: json['role']?.toString() ?? 'STUDENT',
      status: json['status']?.toString() ?? '',
      token: json['token']?.toString(),
      organization: OrganizationInviteOrganizationModel.fromJson(
        organizationJson,
      ),
      overview: overviewJson == null
          ? null
          : OrganizationInviteOverviewModel.fromJson(overviewJson),
      invitedByName: json['invitedByName']?.toString(),
      expiresAt: _readDateTime(json['expiresAt']),
      maxUses: _readNullableInt(json['maxUses']),
      usedCount: _readInt(json['usedCount']),
      alreadyJoined: _readBool(json['alreadyJoined'] ?? json['viewerJoined']),
    );
  }
}

int _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _readNullableInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

DateTime? _readDateTime(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

bool _readBool(Object? value) {
  if (value is bool) return value;
  return value?.toString().toLowerCase() == 'true';
}
