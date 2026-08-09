import '../entities/app_notification_entity.dart';

abstract class NotificationRepository {
  Future<List<AppNotificationEntity>> getNotifications({
    int page = 0,
    int size = 20,
  });

  Future<int> getUnreadCount();

  Future<void> markAsRead(int id);

  Future<void> markAllAsRead();

  Future<void> registerDevice(String token);

  Future<void> deactivateDevice(String token);
}
