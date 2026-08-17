import '../../domain/entities/friend_entity.dart';
import '../../domain/entities/friend_request_entity.dart';
import '../../domain/entities/search_user_entity.dart';
import '../../domain/entities/user_profile_entity.dart';

abstract class FriendsRepository {
  Future<List<FriendEntity>> getFriends({int page, int size});

  Future<List<FriendRequestEntity>> getReceivedRequests({int page, int size});

  Future<List<FriendRequestEntity>> getSentRequests({int page, int size});

  Future<void> sendRequest(int userId);

  Future<void> acceptRequest(int requestId);

  Future<void> rejectRequest(int requestId);

  Future<void> cancelRequest(int requestId);

  Future<void> removeFriend(int friendId);

  Future<List<SearchUserEntity>> searchUsers(String query);

  Future<UserProfileEntity> getUserProfile(int userId);
}
