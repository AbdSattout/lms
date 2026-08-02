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