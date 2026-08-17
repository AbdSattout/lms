import '../repositories/friends_repository.dart';

class RemoveFriendUseCase {
  final FriendsRepository repository;

  RemoveFriendUseCase(this.repository);

  Future<void> call(int friendId) => repository.removeFriend(friendId);
}
