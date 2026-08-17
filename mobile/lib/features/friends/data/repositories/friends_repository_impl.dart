import '../../domain/entities/friend_entity.dart';
import '../../domain/entities/friend_request_entity.dart';
import '../../domain/entities/search_user_entity.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/friends_repository.dart';
import '../datasources/friends_remote_datasource.dart';

class FriendsRepositoryImpl implements FriendsRepository {
  final FriendsRemoteDataSource remote;

  FriendsRepositoryImpl(this.remote);

  @override
  Future<List<FriendEntity>> getFriends({int page = 0, int size = 100}) {
    return remote.getFriends(page: page, size: size);
  }

  @override
  Future<List<FriendRequestEntity>> getReceivedRequests({
    int page = 0,
    int size = 100,
  }) {
    return remote.getReceivedRequests(page: page, size: size);
  }

  @override
  Future<List<FriendRequestEntity>> getSentRequests({
    int page = 0,
    int size = 100,
  }) {
    return remote.getSentRequests(page: page, size: size);
  }

  @override
  Future<void> sendRequest(int userId) {
    return remote.sendRequest(userId);
  }

  @override
  Future<void> acceptRequest(int requestId) {
    return remote.acceptRequest(requestId);
  }

  @override
  Future<void> rejectRequest(int requestId) {
    return remote.rejectRequest(requestId);
  }

  @override
  Future<void> cancelRequest(int requestId) {
    return remote.cancelRequest(requestId);
  }

  @override
  Future<void> removeFriend(int friendId) {
    return remote.removeFriend(friendId);
  }

  @override
  Future<List<SearchUserEntity>> searchUsers(String query) {
    return remote.searchUsers(query);
  }

  @override
  Future<UserProfileEntity> getUserProfile(int userId) {
    return remote.getUserProfile(userId);
  }
}
