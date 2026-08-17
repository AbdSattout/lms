import '../repositories/friends_repository.dart';

class SendFriendRequestUseCase {
  final FriendsRepository repository;

  SendFriendRequestUseCase(this.repository);

  Future<void> call(int userId) => repository.sendRequest(userId);
}
