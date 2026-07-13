class CourseProgressEntity {
  final int? lastLessonId;
  final int? lastBlockId;
  final double progressPercentage;
  final bool completed;
  final DateTime? completedAt;

  const CourseProgressEntity({
    this.lastLessonId,
    this.lastBlockId,
    this.progressPercentage = 0,
    this.completed = false,
    this.completedAt,
  });
}

class CourseEntity {
  final int id;
  final String title;
  final String slug;
  final String? description;
  final String? coverUrl;
  final String? organizationName;
  final CourseProgressEntity? progress;

  final String? status;

  const CourseEntity({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    this.coverUrl,
    this.organizationName,
    this.progress,
    this.status,
  });
}

class CourseEnrollmentEntity {
  final int courseId;
  final String courseTitle;
  final DateTime enrolledAt;

  const CourseEnrollmentEntity({
    required this.courseId,
    required this.courseTitle,
    required this.enrolledAt,
  });
}