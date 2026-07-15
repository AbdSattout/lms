import '../../domain/entities/course_entity.dart';

class CourseProgressModel extends CourseProgressEntity {
  const CourseProgressModel({
    super.lastLessonId,
    super.lastBlockId,
    super.progressPercentage,
    super.completed,
    super.completedAt,
  });

  factory CourseProgressModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CourseProgressModel();

    return CourseProgressModel(
      lastLessonId: json['lastLessonId'],
      lastBlockId: json['lastBlockId'],
      progressPercentage:
      (json['progressPercentage'] as num?)?.toDouble() ?? 0,
      completed: json['completed'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'])
          : null,
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
    super.progress,
    super.status,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      coverUrl: json['coverUrl'],
      organizationName: json['organizationName'],
      progress: CourseProgressModel.fromJson(
        json['progress'] as Map<String, dynamic>?,
      ),
      status: json['status'],
    );
  }
}

class CourseEnrollmentModel extends CourseEnrollmentEntity {
  const CourseEnrollmentModel({
    required super.courseId,
    required super.courseTitle,
    required super.enrolledAt,
  });

  factory CourseEnrollmentModel.fromJson(Map<String, dynamic> json) {
    return CourseEnrollmentModel(
      courseId: json['courseId'] ?? 0,
      courseTitle: json['courseTitle'] ?? '',
      enrolledAt:
      DateTime.tryParse(json['enrolledAt'] ?? '') ?? DateTime.now(),
    );
  }
}