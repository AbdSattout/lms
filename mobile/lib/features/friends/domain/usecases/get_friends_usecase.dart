import '../entities/friend_entity.dart';
import '../repositories/friends_repository.dart';

class GetFriendsUseCase {
  final FriendsRepository repository;

  GetFriendsUseCase(this.repository);

  Future<List<FriendEntity>> call({int page = 0, int size = 100}) {
    return repository.getFriends(page: page, size: size);
  }
}
