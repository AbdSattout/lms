import '../repositories/notification_repository.dart';

class GetUnreadNotificationCountUseCase {
  final NotificationRepository repository;

  GetUnreadNotificationCountUseCase(this.repository);

  Future<int> call() {
    return repository.getUnreadCount();
  }
}
