import 'organization_entity.dart';

class OrganizationInviteOrganizationEntity {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? imageUrl;
  final OrganizationVisibility visibility;
  final String? ownerName;

  const OrganizationInviteOrganizationEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.imageUrl,
    this.visibility = OrganizationVisibility.unknown,
    this.ownerName,
  });
}

class OrganizationInviteOverviewEntity {
  final int membersCount;
  final int adminsCount;
  final int studentsCount;
  final int coursesCount;
  final int publishedCoursesCount;

  const OrganizationInviteOverviewEntity({
    this.membersCount = 0,
    this.adminsCount = 0,
    this.studentsCount = 0,
    this.coursesCount = 0,
    this.publishedCoursesCount = 0,
  });
}

class OrganizationInviteEntity {
  final int id;
  final int? userId;
  final String? userName;
  final String role;
  final String status;
  final String? token;
  final OrganizationInviteOrganizationEntity organization;
  final OrganizationInviteOverviewEntity? overview;
  final String? invitedByName;
  final DateTime? expiresAt;
  final int? maxUses;
  final int usedCount;
  final bool alreadyJoined;

  const OrganizationInviteEntity({
    required this.id,
    this.userId,
    this.userName,
    required this.role,
    required this.status,
    this.token,
    required this.organization,
    this.overview,
    this.invitedByName,
    this.expiresAt,
    this.maxUses,
    this.usedCount = 0,
    this.alreadyJoined = false,
  });

  bool get isPending => status.toUpperCase() == 'PENDING';
}
