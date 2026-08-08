import '../../domain/entities/activity_entity.dart';

class ActivityModel extends ActivityEntity {
  const ActivityModel({
    required super.date,
    required super.xpEarned,
    required super.completedBlocks,
    required super.completedLessons,
    required super.completedChapters,
    required super.completedCourses,
    required super.completedPracticeQuizzes,
    required super.completedFinalQuizzes,
    required super.completedQuizzes,
    required super.correctQuestions,
    required super.enrollments,
    required super.totalActions,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      date: json['date'] ?? '',
      xpEarned: json['xpEarned'] ?? 0,
      completedBlocks: json['completedBlocks'] ?? 0,
      completedLessons: json['completedLessons'] ?? 0,
      completedChapters: json['completedChapters'] ?? 0,
      completedCourses: json['completedCourses'] ?? 0,
      completedPracticeQuizzes: json['completedPracticeQuizzes'] ?? 0,
      completedFinalQuizzes: json['completedFinalQuizzes'] ?? 0,
      completedQuizzes: json['completedQuizzes'] ?? 0,
      correctQuestions: json['correctQuestions'] ?? 0,
      enrollments: json['enrollments'] ?? 0,
      totalActions: json['totalActions'] ?? 0,
    );
  }
}