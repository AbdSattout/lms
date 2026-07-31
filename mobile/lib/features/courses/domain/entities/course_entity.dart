/// Lock/progress state shared by chapters, lessons, and blocks. Confirmed
/// values so far: LOCKED, CURRENT, COMPLETED.
enum ContentStatus {
  locked,
  current,
  completed,
  unknown;

  static ContentStatus fromApi(String? value) {
    switch (value) {
      case 'LOCKED':
        return ContentStatus.locked;
      case 'CURRENT':
        return ContentStatus.current;
      case 'COMPLETED':
        return ContentStatus.completed;
      default:
        return ContentStatus.unknown;
    }
  }
}

class BlockEntity {
  final int id;
  final String title;
  final int position;
  final ContentStatus status;

  const BlockEntity({
    required this.id,
    required this.title,
    required this.position,
    required this.status,
  });
}

class LessonEntity {
  final int id;
  final String title;
  final int position;
  final ContentStatus status;
  final List<BlockEntity> blocks;

  const LessonEntity({
    required this.id,
    required this.title,
    required this.position,
    required this.status,
    this.blocks = const [],
  });
}

class ChapterEntity {
  final int id;
  final String title;
  final int position;
  final ContentStatus status;
  final List<LessonEntity> lessons;

  const ChapterEntity({
    required this.id,
    required this.title,
    required this.position,
    required this.status,
    this.lessons = const [],
  });
}

/// The "progress" object embedded directly in GET /courses/{id}. Has a
/// REAL "completed" boolean — this is the authoritative source for
/// "is this course finished," not CourseEnrollmentDetailsEntity's guess.
class CourseProgressSnapshotEntity {
  final int? currentChapterId;
  final int? currentLessonId;
  final int? currentBlockId;
  final double progressPercentage;
  final bool completed;
  final DateTime? completedAt;

  const CourseProgressSnapshotEntity({
    this.currentChapterId,
    this.currentLessonId,
    this.currentBlockId,
    required this.progressPercentage,
    required this.completed,
    this.completedAt,
  });
}

/// The ongoing enrollment record from GET /courses/me/enrollments.
/// Authoritative for placementTestCompleted / enrolledAt / status — NOT
/// for "is this course completed" (see isCompleted below and
/// CourseEntity.isCompleted, which is the one to actually use).
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

  // GUESS, kept only as CourseEntity.isCompleted's fallback for contexts
  // where progressSnapshot isn't available (e.g. My Courses list, which
  // never fetches /courses/{id}). Don't use this directly anymore.
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
  final List<ChapterEntity> chapters;
  final CourseProgressSnapshotEntity? progressSnapshot;

  const CourseEntity({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    this.coverUrl,
    this.organizationName,
    this.status,
    this.enrollment,
    this.chapters = const [],
    this.progressSnapshot,
  });

  /// FIX: this is now the single place to check "is this course done."
  /// Prefers the real completed boolean from /courses/{id}'s progress
  /// snapshot; falls back to the enrollment-based guess only when that
  /// snapshot isn't available (i.e. we only have list-level data).
  bool get isCompleted =>
      progressSnapshot?.completed ?? (enrollment?.isCompleted ?? false);
}

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