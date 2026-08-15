import '../repositories/friends_repository.dart';

class RejectFriendRequestUseCase {
  final FriendsRepository repository;

  RejectFriendRequestUseCase(this.repository);

  Future<void> call(int requestId) => repository.rejectRequest(requestId);
}
