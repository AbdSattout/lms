abstract class PublicOrganizationInviteEvent {}

class PreviewPublicOrganizationInviteEvent
    extends PublicOrganizationInviteEvent {
  final String token;

  PreviewPublicOrganizationInviteEvent(this.token);
}

class AcceptPublicOrganizationInviteEvent
    extends PublicOrganizationInviteEvent {
  final String token;

  AcceptPublicOrganizationInviteEvent(this.token);
}

class ResetPublicOrganizationInviteEvent
    extends PublicOrganizationInviteEvent {}
