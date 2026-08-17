import '../../../../core/databases/api/api_consumer.dart';
import '../../../../core/databases/api/end_points.dart';
import '../../../../core/models/page_response.dart';
import '../models/friend_model.dart';
import '../models/friend_request_model.dart';
import '../models/search_user_model.dart';
import '../models/user_profile_model.dart';

abstract class FriendsRemoteDataSource {
  Future<List<FriendModel>> getFriends({int page, int size});

  Future<List<FriendRequestModel>> getReceivedRequests({int page, int size});

  Future<List<FriendRequestModel>> getSentRequests({int page, int size});

  Future<void> sendRequest(int userId);

  Future<void> acceptRequest(int requestId);

  Future<void> rejectRequest(int requestId);

  Future<void> cancelRequest(int requestId);

  Future<void> removeFriend(int friendId);

  Future<List<SearchUserModel>> searchUsers(String query);

  Future<UserProfileModel> getUserProfile(int userId);
}

class FriendsRemoteDataSourceImpl implements FriendsRemoteDataSource {
  final ApiConsumer api;

  FriendsRemoteDataSourceImpl(this.api);

  @override
  Future<List<FriendModel>> getFriends({int page = 0, int size = 100}) async {
    final response = await api.get(
      EndPoints.friends,
      queryParameters: {'page': page, 'size': size},
    );

    final pageResponse = PageResponse<FriendModel>.fromJson(
      response,
      FriendModel.fromJson,
    );

    return pageResponse.content;
  }

  @override
  Future<List<FriendRequestModel>> getReceivedRequests({
    int page = 0,
    int size = 100,
  }) async {
    final response = await api.get(
      EndPoints.receivedFriendRequests,
      queryParameters: {'page': page, 'size': size},
    );

    final pageResponse = PageResponse<FriendRequestModel>.fromJson(
      response,
      FriendRequestModel.fromJson,
    );

    return pageResponse.content;
  }

  @override
  Future<List<FriendRequestModel>> getSentRequests({
    int page = 0,
    int size = 100,
  }) async {
    final response = await api.get(
      EndPoints.sentFriendRequests,
      queryParameters: {'page': page, 'size': size},
    );

    final pageResponse = PageResponse<FriendRequestModel>.fromJson(
      response,
      FriendRequestModel.fromJson,
    );

    return pageResponse.content;
  }

  @override
  Future<void> sendRequest(int userId) {
    return api.post(EndPoints.sendFriendRequest(userId));
  }

  @override
  Future<void> acceptRequest(int requestId) {
    return api.patch(EndPoints.acceptFriendRequest(requestId));
  }

  @override
  Future<void> rejectRequest(int requestId) {
    return api.patch(EndPoints.rejectFriendRequest(requestId));
  }

  @override
  Future<void> cancelRequest(int requestId) {
    return api.delete(EndPoints.cancelFriendRequest(requestId));
  }

  @override
  Future<void> removeFriend(int friendId) {
    return api.delete(EndPoints.removeFriend(friendId));
  }

  @override
  Future<List<SearchUserModel>> searchUsers(String query) async {
    final response = await api.get(
      EndPoints.usersSearch,
      queryParameters: {'q': query},
    );

    final list = response is List ? response : const [];
    return list.map((e) => SearchUserModel.fromJson(e)).toList();
  }

  @override
  Future<UserProfileModel> getUserProfile(int userId) async {
    final response = await api.get(EndPoints.userProfile(userId));
    return UserProfileModel.fromJson(response);
  }
}
