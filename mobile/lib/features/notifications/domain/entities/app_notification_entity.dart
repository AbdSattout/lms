class AppNotificationEntity {
  final int id;
  final String type;
  final String title;
  final String message;
  final String? referenceType;
  final int? referenceId;
  final bool read;
  final DateTime? readAt;
  final DateTime? createdAt;

  const AppNotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.referenceType,
    this.referenceId,
    required this.read,
    this.readAt,
    this.createdAt,
  });

  bool get isOrganizationInvite => type == 'ORGANIZATION_INVITE';
}
