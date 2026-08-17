import '../entities/friend_request_entity.dart';
import '../repositories/friends_repository.dart';

class GetReceivedFriendRequestsUseCase {
  final FriendsRepository repository;

  GetReceivedFriendRequestsUseCase(this.repository);

  Future<List<FriendRequestEntity>> call({int page = 0, int size = 100}) {
    return repository.getReceivedRequests(page: page, size: size);
  }
}
