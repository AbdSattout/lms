enum OrganizationVisibility {
  public,
  private,
  unknown;

  static OrganizationVisibility fromApi(String? value) {
    switch (value) {
      case 'PUBLIC':
        return OrganizationVisibility.public;
      case 'PRIVATE':
      case 'INVITE-ONLY':
      case 'INVITE_ONLY':
        return OrganizationVisibility.private;
      default:
        return OrganizationVisibility.unknown;
    }
  }
}

class OrganizationMemberEntity {
  final int memberId;
  final String? role;
  final DateTime? joinedAt;

  const OrganizationMemberEntity({
    required this.memberId,
    this.role,
    this.joinedAt,
  });
}

class OrganizationEntity {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? image;
  final OrganizationVisibility visibility;
  final bool verified;
  final String? ownerName;
  final int membersCount;

  final bool viewerJoined;
  final String? viewerRole;
  final String? joinRequestStatus;
  final int? inviteId;
  final String? inviteStatus;
  final OrganizationMemberEntity? member;

  const OrganizationEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.image,
    this.visibility = OrganizationVisibility.unknown,
    this.verified = false,
    this.ownerName,
    this.membersCount = 0,
    this.viewerJoined = false,
    this.viewerRole,
    this.joinRequestStatus,
    this.inviteId,
    this.inviteStatus,
    this.member,
  });
  bool get isOwner => viewerRole?.toUpperCase() == 'OWNER';
  bool get isAdmin => viewerRole?.toUpperCase() == 'ADMIN';
}
