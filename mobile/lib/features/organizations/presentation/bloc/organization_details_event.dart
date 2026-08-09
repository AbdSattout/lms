abstract class OrganizationDetailsEvent {}

class GetOrganizationDetailsEvent extends OrganizationDetailsEvent {
  final String slug;
  GetOrganizationDetailsEvent(this.slug);
}

class JoinOrganizationEvent extends OrganizationDetailsEvent {
  final String slug;
  JoinOrganizationEvent(this.slug);
}

class LeaveOrganizationEvent extends OrganizationDetailsEvent {
  final String slug;
  LeaveOrganizationEvent(this.slug);
}

class CancelJoinRequestEvent extends OrganizationDetailsEvent {
  final String slug;
  CancelJoinRequestEvent(this.slug);
}

class AcceptOrganizationDetailsInviteEvent extends OrganizationDetailsEvent {
  final String slug;
  final int inviteId;
  AcceptOrganizationDetailsInviteEvent({
    required this.slug,
    required this.inviteId,
  });
}

class DeleteOrganizationEvent extends OrganizationDetailsEvent {
  final String slug;
  DeleteOrganizationEvent(this.slug);
}
