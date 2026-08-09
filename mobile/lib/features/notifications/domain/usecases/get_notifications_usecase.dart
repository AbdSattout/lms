import '../entities/app_notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<List<AppNotificationEntity>> call({int page = 0, int size = 20}) {
    return repository.getNotifications(page: page, size: size);
  }
}
