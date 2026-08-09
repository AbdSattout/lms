abstract class PublicOrganizationInviteEvent {}

class AcceptPublicOrganizationInviteEvent
    extends PublicOrganizationInviteEvent {
  final String token;

  AcceptPublicOrganizationInviteEvent(this.token);
}

class ResetPublicOrganizationInviteEvent
    extends PublicOrganizationInviteEvent {}
