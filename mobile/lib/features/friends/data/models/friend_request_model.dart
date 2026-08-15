import '../../../../core/utils/date_time_utils.dart';
import '../../domain/entities/friend_request_entity.dart';
import 'friend_user_model.dart';

class FriendRequestModel extends FriendRequestEntity {
  const FriendRequestModel({
    required super.id,
    required super.sender,
    required super.receiver,
    required super.status,
    super.createdAt,
  });

  factory FriendRequestModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};

    return FriendRequestModel(
      id: _readInt(map['id']),
      sender: FriendUserModel.fromJson(map['sender']),
      receiver: FriendUserModel.fromJson(map['receiver']),
      status: map['status']?.toString() ?? '',
      createdAt: parseApiDateTime(map['createdAt']),
    );
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
