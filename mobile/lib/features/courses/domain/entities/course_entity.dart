import '../../../organizations/domain/entities/organization_entity.dart'
    show OrganizationVisibility;

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

/// NEW — confirmed nested shape from GET /courses, GET /organizations/
/// {slug}/courses, and GET /organizations/{orgSlug}/courses/{courseSlug}.
/// This is what makes org+course-slug-based navigation possible (Course
/// Details needs orgSlug to fetch itself). NOT present on GET /courses/{id}
/// or GET /courses/me/enrollments — those only give the flat
/// organizationName string, hence CourseEntity keeping both.
class CourseOrganizationRef {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? image;
  final OrganizationVisibility visibility;

  // NOT YET LIVE on this endpoint as of this writing (backend confirmed
  // "eventually" adding it) — deliberately nullable. null must mean
  // "unknown / not yet provided," never treated the same as false
  // ("confirmed not a member"). Defaulting this to false would hide
  // Enroll for every course the moment this field is absent, which is
  // exactly the regression to avoid.
  final bool? viewerJoined;
  final String? viewerRole;

  const CourseOrganizationRef({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.image,
    this.visibility = OrganizationVisibility.unknown,
    this.viewerJoined,
    this.viewerRole,
  });
}

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

class CourseEnrollmentDetailsEntity {
  final int id;
  final int courseId;
  final String courseTitle;
  final DateTime? enrolledAt;
  final String status;
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

  // Two ways an org can show up depending on which endpoint this course
  // came from — see CourseOrganizationRef doc above. Use
  // organizationDisplayName for display; use `organization` specifically
  // when you need the org's slug (e.g. to navigate/fetch by org+course
  // slug).
  final String? organizationName;
  final CourseOrganizationRef? organization;

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
    this.organization,
    this.status,
    this.enrollment,
    this.chapters = const [],
    this.progressSnapshot,
  });

  String? get organizationDisplayName => organization?.name ?? organizationName;

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