import '../../domain/entities/course_entity.dart';

class RewardModel extends RewardEntity {
  const RewardModel({
    required super.eventType,
    super.referenceId,
    required super.awarded,
    required super.xpAwarded,
    required super.totalXp,
    required super.previousLevelNumber,
    required super.currentLevelNumber,
    required super.currentLevelTitle,
    required super.leveledUp,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      eventType: json['eventType'] ?? '',
      referenceId: json['referenceId'],
      awarded: json['awarded'] ?? false,
      xpAwarded: json['xpAwarded'] ?? 0,
      totalXp: json['totalXp'] ?? 0,
      previousLevelNumber: json['previousLevelNumber'] ?? 0,
      currentLevelNumber: json['currentLevelNumber'] ?? 0,
      currentLevelTitle: json['currentLevelTitle'] ?? '',
      leveledUp: json['leveledUp'] ?? false,
    );
  }
}

class CourseEnrollmentDetailsModel extends CourseEnrollmentDetailsEntity {
  const CourseEnrollmentDetailsModel({
    required super.id,
    required super.courseId,
    required super.courseTitle,
    super.enrolledAt,
    required super.status,
    required super.placementTestCompleted,
    required super.progressPercentage,
    super.currentChapterId,
    super.currentLessonId,
    super.currentBlockId,
  });

  factory CourseEnrollmentDetailsModel.fromJson(Map<String, dynamic> json) {
    return CourseEnrollmentDetailsModel(
      id: json['id'] ?? 0,
      courseId: json['courseId'] ?? 0,
      courseTitle: json['courseTitle'] ?? '',
      enrolledAt: json['enrolledAt'] != null
          ? DateTime.tryParse(json['enrolledAt'])
          : null,
      status: json['status'] ?? '',
      placementTestCompleted: json['placementTestCompleted'] ?? false,
      progressPercentage:
      (json['progressPercentage'] as num?)?.toDouble() ?? 0,
      currentChapterId: json['currentChapterId'],
      currentLessonId: json['currentLessonId'],
      currentBlockId: json['currentBlockId'],
    );
  }
}

class CourseModel extends CourseEntity {
  const CourseModel({
    required super.id,
    required super.title,
    required super.slug,
    super.description,
    super.coverUrl,
    super.organizationName,
    super.status,
    super.enrollment,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      coverUrl: json['coverUrl'],
      organizationName: json['organizationName'],
      status: json['status'],
      enrollment: json['enrollment'] != null
          ? CourseEnrollmentDetailsModel.fromJson(
        json['enrollment'] as Map<String, dynamic>,
      )
          : null,
    );
  }
}

class EnrollActionResultModel extends EnrollActionResultEntity {
  const EnrollActionResultModel({
    required super.courseId,
    required super.courseTitle,
    required super.enrolledAt,
    super.rewards,
  });

  factory EnrollActionResultModel.fromJson(Map<String, dynamic> json) {
    return EnrollActionResultModel(
      courseId: json['courseId'] ?? 0,
      courseTitle: json['courseTitle'] ?? '',
      enrolledAt:
      DateTime.tryParse(json['enrolledAt'] ?? '') ?? DateTime.now(),
      rewards: (json['rewards'] as List? ?? [])
          .map((r) => RewardModel.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}