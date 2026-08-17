import '../repositories/friends_repository.dart';

class AcceptFriendRequestUseCase {
  final FriendsRepository repository;

  AcceptFriendRequestUseCase(this.repository);

  Future<void> call(int requestId) => repository.acceptRequest(requestId);
}
