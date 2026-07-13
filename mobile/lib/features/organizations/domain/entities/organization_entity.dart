enum OrganizationVisibility {
  public,
  private,
  inviteOnly,
  unknown;

  static OrganizationVisibility fromApi(String? value) {
    switch (value) {
      case 'PUBLIC':
        return OrganizationVisibility.public;
      case 'PRIVATE':
        return OrganizationVisibility.private;
      case 'INVITE-ONLY':
      case 'INVITE_ONLY':
        return OrganizationVisibility.inviteOnly;
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

  const OrganizationEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.image,
    this.visibility = OrganizationVisibility.unknown,
    this.ownerName,
  });
}