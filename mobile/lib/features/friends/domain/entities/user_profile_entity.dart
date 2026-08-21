import '../../../gamification/domain/entities/streak_entity.dart';
import 'friend_user_entity.dart';

class UserProfileEntity {
  final UserProfileDataEntity profile;
  final UserProfileFriendshipEntity friendship;
  final UserProfileStatsEntity stats;
  final UserProfileGamificationEntity gamification;
  final List<UserBadgeEntity> badges;
  final List<UserRecentCourseEntity> recentCourses;

  const UserProfileEntity({
    required this.profile,
    required this.friendship,
    required this.stats,
    required this.gamification,
    this.badges = const [],
    this.recentCourses = const [],
  });
}

class UserProfileDataEntity {
  final String name;
  final String? email;
  final String? phone;
  final String? university;
  final FriendUserEntity user;

  const UserProfileDataEntity({
    required this.name,
    required this.user,
    this.email,
    this.phone,
    this.university,
  });
}

class UserProfileFriendshipEntity {
  final String status;
  final bool canSendFriendRequest;
  final int? pendingRequestId;
  final int? friendId;

  const UserProfileFriendshipEntity({
    required this.status,
    required this.canSendFriendRequest,
    this.pendingRequestId,
    this.friendId,
  });
}

class UserProfileStatsEntity {
  final int friendsCount;
  final int organizationsCount;
  final int enrolledCoursesCount;
  final int completedCoursesCount;
  final int followingRoadmapsCount;
  final int completedRoadmapsCount;
  final int certificatesCount;

  const UserProfileStatsEntity({
    required this.friendsCount,
    required this.organizationsCount,
    required this.enrolledCoursesCount,
    required this.completedCoursesCount,
    required this.followingRoadmapsCount,
    required this.completedRoadmapsCount,
    required this.certificatesCount,
  });
}

class UserProfileGamificationEntity {
  final int? totalXp;
  final int? levelNumber;
  final String? levelTitle;
  final String? tier;
  final StreakEntity? streak;

  const UserProfileGamificationEntity({
    this.totalXp,
    this.levelNumber,
    this.levelTitle,
    this.tier,
    this.streak,
  });
}

class UserBadgeEntity {
  final int badgeId;
  final int userBadgeId;
  final String code;
  final String title;
  final String description;
  final String? iconUrl;
  final DateTime? earnedAt;

  const UserBadgeEntity({
    required this.badgeId,
    required this.userBadgeId,
    required this.code,
    required this.title,
    required this.description,
    this.iconUrl,
    this.earnedAt,
  });
}

class UserRecentCourseEntity {
  final int id;
  final String title;
  final String slug;
  final String? coverUrl;
  final String? organizationName;
  final String? organizationSlug;

  const UserRecentCourseEntity({
    required this.id,
    required this.title,
    required this.slug,
    this.coverUrl,
    this.organizationName,
    this.organizationSlug,
  });
}
