import '../../domain/entities/organization_invite_entity.dart';

enum PublicOrganizationInviteStatus {
  initial,
  previewing,
  previewed,
  accepting,
  accepted,
  error,
}

class PublicOrganizationInviteState {
  final PublicOrganizationInviteStatus status;
  final String? message;
  final OrganizationInviteEntity? invite;
  final String? token;

  const PublicOrganizationInviteState({
    required this.status,
    this.message,
    this.invite,
    this.token,
  });

  const PublicOrganizationInviteState.initial()
    : status = PublicOrganizationInviteStatus.initial,
      message = null,
      invite = null,
      token = null;

  bool get isPreviewing => status == PublicOrganizationInviteStatus.previewing;
  bool get isPreviewed => status == PublicOrganizationInviteStatus.previewed;
  bool get isAccepting => status == PublicOrganizationInviteStatus.accepting;
  bool get isAccepted => status == PublicOrganizationInviteStatus.accepted;
  bool get hasError => status == PublicOrganizationInviteStatus.error;
  bool get alreadyJoined => invite?.alreadyJoined ?? false;

  PublicOrganizationInviteState copyWith({
    PublicOrganizationInviteStatus? status,
    String? message,
    OrganizationInviteEntity? invite,
    String? token,
    bool clearMessage = false,
    bool clearInvite = false,
    bool clearToken = false,
  }) {
    return PublicOrganizationInviteState(
      status: status ?? this.status,
      message: clearMessage ? null : message ?? this.message,
      invite: clearInvite ? null : invite ?? this.invite,
      token: clearToken ? null : token ?? this.token,
    );
  }
}
