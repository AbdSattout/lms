import '../../../../core/utils/date_time_utils.dart';
import '../../../gamification/data/models/streak_model.dart';
import '../../domain/entities/user_profile_entity.dart';
import 'friend_user_model.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.profile,
    required super.friendship,
    required super.stats,
    required super.gamification,
    super.badges,
    super.recentCourses,
  });

  factory UserProfileModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};

    return UserProfileModel(
      profile: ProfileModel.fromJson(map['profile']),
      friendship: FriendshipModel.fromJson(map['friendship']),
      stats: StatsModel.fromJson(map['stats']),
      gamification: GamificationModel.fromJson(map['gamification']),
      badges: (map['badges'] as List? ?? [])
          .map((e) => UserBadgeModel.fromJson(e))
          .toList(),
      recentCourses: (map['recentCourses'] as List? ?? [])
          .map((e) => RecentCourseModel.fromJson(e))
          .toList(),
    );
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _readNullableInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static String _readString(Object? value) {
    return value?.toString().trim() ?? '';
  }

  static String? _readNullableString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}

class ProfileModel extends UserProfileDataEntity {
  const ProfileModel({
    required super.name,
    required super.user,
    super.email,
    super.phone,
    super.university,
  });

  factory ProfileModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};

    return ProfileModel(
      name: UserProfileModel._readString(map['name']),
      email: UserProfileModel._readNullableString(map['email']),
      phone: UserProfileModel._readNullableString(map['phone']),
      university: UserProfileModel._readNullableString(map['university']),
      user: FriendUserModel.fromJson(map['user']),
    );
  }
}

class FriendshipModel extends UserProfileFriendshipEntity {
  const FriendshipModel({
    required super.status,
    required super.canSendFriendRequest,
    super.pendingRequestId,
  });

  factory FriendshipModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};

    return FriendshipModel(
      status: UserProfileModel._readString(map['status']),
      canSendFriendRequest: map['canSendFriendRequest'] == true,
      pendingRequestId: UserProfileModel._readNullableInt(
        map['pendingRequestId'],
      ),
    );
  }
}

class StatsModel extends UserProfileStatsEntity {
  const StatsModel({
    required super.friendsCount,
    required super.organizationsCount,
    required super.enrolledCoursesCount,
    required super.completedCoursesCount,
    required super.followingRoadmapsCount,
    required super.completedRoadmapsCount,
    required super.certificatesCount,
  });

  factory StatsModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};

    return StatsModel(
      friendsCount: UserProfileModel._readInt(map['friendsCount']),
      organizationsCount: UserProfileModel._readInt(map['organizationsCount']),
      enrolledCoursesCount: UserProfileModel._readInt(
        map['enrolledCoursesCount'],
      ),
      completedCoursesCount: UserProfileModel._readInt(
        map['completedCoursesCount'],
      ),
      followingRoadmapsCount: UserProfileModel._readInt(
        map['followingRoadmapsCount'],
      ),
      completedRoadmapsCount: UserProfileModel._readInt(
        map['completedRoadmapsCount'],
      ),
      certificatesCount: UserProfileModel._readInt(map['certificatesCount']),
    );
  }
}

class GamificationModel extends UserProfileGamificationEntity {
  const GamificationModel({
    super.totalXp,
    super.levelNumber,
    super.levelTitle,
    super.tier,
    super.streak,
  });

  factory GamificationModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};

    return GamificationModel(
      totalXp: UserProfileModel._readNullableInt(map['totalXp']),
      levelNumber: UserProfileModel._readNullableInt(map['levelNumber']),
      levelTitle: UserProfileModel._readNullableString(map['levelTitle']),
      tier: UserProfileModel._readNullableString(map['tier']),
      streak: map['streak'] is Map<String, dynamic>
          ? StreakModel.fromJson(map['streak'] as Map<String, dynamic>)
          : null,
    );
  }
}

class UserBadgeModel extends UserBadgeEntity {
  const UserBadgeModel({
    required super.badgeId,
    required super.userBadgeId,
    required super.code,
    required super.title,
    required super.description,
    super.iconUrl,
    super.earnedAt,
  });

  factory UserBadgeModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};

    return UserBadgeModel(
      badgeId: UserProfileModel._readInt(map['badgeId']),
      userBadgeId: UserProfileModel._readInt(map['userBadgeId']),
      code: UserProfileModel._readString(map['code']),
      title: UserProfileModel._readString(map['title']),
      description: UserProfileModel._readString(map['description']),
      iconUrl: UserProfileModel._readNullableString(map['iconUrl']),
      earnedAt: parseApiDateTime(map['earnedAt']),
    );
  }
}

class RecentCourseModel extends UserRecentCourseEntity {
  const RecentCourseModel({
    required super.id,
    required super.title,
    required super.slug,
    super.coverUrl,
    super.organizationName,
    super.organizationSlug,
  });

  factory RecentCourseModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};
    final organization = map['organization'] is Map<String, dynamic>
        ? map['organization'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return RecentCourseModel(
      id: UserProfileModel._readInt(map['id']),
      title: UserProfileModel._readString(map['title']),
      slug: UserProfileModel._readString(map['slug']),
      coverUrl: UserProfileModel._readNullableString(map['coverUrl']),
      organizationName: UserProfileModel._readNullableString(
        organization['name'],
      ),
      organizationSlug: UserProfileModel._readNullableString(
        organization['slug'],
      ),
    );
  }
}
