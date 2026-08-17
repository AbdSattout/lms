import '../repositories/friends_repository.dart';

class CancelFriendRequestUseCase {
  final FriendsRepository repository;

  CancelFriendRequestUseCase(this.repository);

  Future<void> call(int requestId) => repository.cancelRequest(requestId);
}
