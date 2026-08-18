import '../../../../core/utils/date_time_utils.dart';
import '../../domain/entities/friend_entity.dart';
import 'friend_user_model.dart';

class FriendModel extends FriendEntity {
  const FriendModel({required super.id, required super.user, super.createdAt});

  factory FriendModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};

    return FriendModel(
      id: _readInt(map['id']),
      user: FriendUserModel.fromJson(map['user']),
      createdAt: parseApiDateTime(map['createdAt']),
    );
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
