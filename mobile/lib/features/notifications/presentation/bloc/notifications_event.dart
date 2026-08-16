import '../../../organizations/domain/entities/organization_invite_entity.dart';
import '../../domain/entities/app_notification_entity.dart';

abstract class NotificationsEvent {}

class LoadNotificationsEvent extends NotificationsEvent {}

class RefreshNotificationsEvent extends NotificationsEvent {
  final bool keepHigherUnreadCount;

  RefreshNotificationsEvent({this.keepHigherUnreadCount = false});
}

class NotificationReceivedEvent extends NotificationsEvent {}

class AcceptOrganizationInviteEvent extends NotificationsEvent {
  final OrganizationInviteEntity invite;

  AcceptOrganizationInviteEvent(this.invite);
}

class DeclineOrganizationInviteEvent extends NotificationsEvent {
  final OrganizationInviteEntity invite;

  DeclineOrganizationInviteEvent(this.invite);
}

class MarkNotificationReadEvent extends NotificationsEvent {
  final AppNotificationEntity notification;

  MarkNotificationReadEvent(this.notification);
}

class MarkAllNotificationsReadEvent extends NotificationsEvent {}
