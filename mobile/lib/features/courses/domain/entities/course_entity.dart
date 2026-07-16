class RewardEntity {
  final String eventType;
  final int? referenceId;
  final bool awarded;
  final int xpAwarded;
  final int totalXp;
  final int previousLevelNumber;
  final int currentLevelNumber;
  final String currentLevelTitle;
  final bool leveledUp;

  const RewardEntity({
    required this.eventType,
    this.referenceId,
    required this.awarded,
    required this.xpAwarded,
    required this.totalXp,
    required this.previousLevelNumber,
    required this.currentLevelNumber,
    required this.currentLevelTitle,
    required this.leveledUp,
  });
}

class CourseEnrollmentDetailsEntity {
  final int id;
  final int courseId;
  final String courseTitle;
  final DateTime? enrolledAt;
  final String status; // e.g. "ACTIVE"
  final bool placementTestCompleted;
  final double progressPercentage;
  final int? currentChapterId;
  final int? currentLessonId;
  final int? currentBlockId;

  const CourseEnrollmentDetailsEntity({
    required this.id,
    required this.courseId,
    required this.courseTitle,
    this.enrolledAt,
    required this.status,
    required this.placementTestCompleted,
    required this.progressPercentage,
    this.currentChapterId,
    this.currentLessonId,
    this.currentBlockId,
  });

  bool get isCompleted => progressPercentage >= 100;
}

class CourseEntity {
  final int id;
  final String title;
  final String slug;
  final String? description;
  final String? coverUrl;
  final String? organizationName;
  final String? status;
  final CourseEnrollmentDetailsEntity? enrollment;

  const CourseEntity({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    this.coverUrl,
    this.organizationName,
    this.status,
    this.enrollment,
  });
}

class EnrollActionResultEntity {
  final int courseId;
  final String courseTitle;
  final DateTime enrolledAt;
  final List<RewardEntity> rewards;

  const EnrollActionResultEntity({
    required this.courseId,
    required this.courseTitle,
    required this.enrolledAt,
    this.rewards = const [],
  });
}