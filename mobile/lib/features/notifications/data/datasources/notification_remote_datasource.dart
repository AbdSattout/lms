import '../../../../core/databases/api/api_consumer.dart';
import '../../../../core/databases/api/end_points.dart';
import '../../../../core/models/page_response.dart';
import '../models/app_notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<AppNotificationModel>> getNotifications({
    int page = 0,
    int size = 20,
  });

  Future<int> getUnreadCount();

  Future<void> markAsRead(int id);

  Future<void> markAllAsRead();

  Future<void> registerDevice(String token);

  Future<void> deactivateDevice(String token);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiConsumer api;

  NotificationRemoteDataSourceImpl(this.api);

  @override
  Future<List<AppNotificationModel>> getNotifications({
    int page = 0,
    int size = 20,
  }) async {
    final response = await api.get(
      EndPoints.notifications,
      queryParameters: {'page': page, 'size': size},
    );

    final notificationsPage = PageResponse<AppNotificationModel>.fromJson(
      response,
      AppNotificationModel.fromJson,
    );

    return notificationsPage.content;
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await api.get(EndPoints.notificationUnreadCount);
    return _readCount(response) ?? 0;
  }

  int? _readCount(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    if (value is Map) {
      for (final key in const [
        'unreadCount',
        'count',
        'total',
        'totalElements',
        'value',
      ]) {
        if (!value.containsKey(key)) continue;
        return _readCount(value[key]) ?? 0;
      }

      return _readCount(value['data']);
    }

    return null;
  }

  @override
  Future<void> markAsRead(int id) {
    return api.patch(EndPoints.notificationRead(id));
  }

  @override
  Future<void> markAllAsRead() {
    return api.patch(EndPoints.notificationsReadAll);
  }

  @override
  Future<void> registerDevice(String token) {
    return api.post(EndPoints.devices, data: {'token': token});
  }

  @override
  Future<void> deactivateDevice(String token) {
    return api.delete(EndPoints.devices, queryParameters: {'token': token});
  }
}
