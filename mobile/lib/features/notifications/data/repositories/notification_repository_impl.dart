import '../../domain/entities/app_notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remote;

  NotificationRepositoryImpl(this.remote);

  @override
  Future<List<AppNotificationEntity>> getNotifications({
    int page = 0,
    int size = 20,
  }) {
    return remote.getNotifications(page: page, size: size);
  }

  @override
  Future<int> getUnreadCount() {
    return remote.getUnreadCount();
  }

  @override
  Future<void> markAsRead(int id) {
    return remote.markAsRead(id);
  }

  @override
  Future<void> markAllAsRead() {
    return remote.markAllAsRead();
  }

  @override
  Future<void> registerDevice(String token) {
    return remote.registerDevice(token);
  }

  @override
  Future<void> deactivateDevice(String token) {
    return remote.deactivateDevice(token);
  }
}
