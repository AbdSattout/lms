import '../../../organizations/domain/entities/organization_invite_entity.dart';
import '../../domain/entities/app_notification_entity.dart';

abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<OrganizationInviteEntity> invites;
  final List<AppNotificationEntity> notifications;
  final int unreadCount;
  final int? processingInviteId;
  final String? actionMessage;
  final String? errorMessage;

  NotificationsLoaded({
    required this.invites,
    required this.notifications,
    required this.unreadCount,
    this.processingInviteId,
    this.actionMessage,
    this.errorMessage,
  });

  bool get hasUnread => unreadCount > 0;

  NotificationsLoaded copyWith({
    List<OrganizationInviteEntity>? invites,
    List<AppNotificationEntity>? notifications,
    int? unreadCount,
    int? processingInviteId,
    bool clearProcessingInviteId = false,
    String? actionMessage,
    bool clearActionMessage = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return NotificationsLoaded(
      invites: invites ?? this.invites,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      processingInviteId: clearProcessingInviteId
          ? null
          : processingInviteId ?? this.processingInviteId,
      actionMessage: clearActionMessage
          ? null
          : actionMessage ?? this.actionMessage,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

class NotificationsError extends NotificationsState {
  final String message;

  NotificationsError(this.message);
}
