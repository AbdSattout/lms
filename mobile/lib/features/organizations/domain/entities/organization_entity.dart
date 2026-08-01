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

class OrganizationEntity {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? image;
  final OrganizationVisibility visibility;
  final String? ownerName;
  final int membersCount;

  final bool viewerJoined;
  final String? viewerRole;

  const OrganizationEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.image,
    this.visibility = OrganizationVisibility.unknown,
    this.ownerName,
    this.membersCount = 0,
    this.viewerJoined = false,
    this.viewerRole,
  });
}