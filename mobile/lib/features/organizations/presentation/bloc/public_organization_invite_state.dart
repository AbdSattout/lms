enum PublicOrganizationInviteStatus { initial, accepting, accepted, error }

class PublicOrganizationInviteState {
  final PublicOrganizationInviteStatus status;
  final String? message;

  const PublicOrganizationInviteState({required this.status, this.message});

  const PublicOrganizationInviteState.initial()
    : status = PublicOrganizationInviteStatus.initial,
      message = null;

  bool get isAccepting => status == PublicOrganizationInviteStatus.accepting;
  bool get isAccepted => status == PublicOrganizationInviteStatus.accepted;
  bool get hasError => status == PublicOrganizationInviteStatus.error;

  PublicOrganizationInviteState copyWith({
    PublicOrganizationInviteStatus? status,
    String? message,
    bool clearMessage = false,
  }) {
    return PublicOrganizationInviteState(
      status: status ?? this.status,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}
