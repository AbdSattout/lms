import '../../../courses/domain/entities/course_entity.dart';

class RecommendedCourseEntity {
  final CourseEntity course;
  final int score;
  final String reason;

  const RecommendedCourseEntity({
    required this.course,
    required this.score,
    required this.reason,
  });
}
