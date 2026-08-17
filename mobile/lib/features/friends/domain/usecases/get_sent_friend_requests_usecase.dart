import '../entities/friend_request_entity.dart';
import '../repositories/friends_repository.dart';

class GetSentFriendRequestsUseCase {
  final FriendsRepository repository;

  GetSentFriendRequestsUseCase(this.repository);

  Future<List<FriendRequestEntity>> call({int page = 0, int size = 100}) {
    return repository.getSentRequests(page: page, size: size);
  }
}
