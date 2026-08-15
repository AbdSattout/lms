import '../../../courses/data/models/course_model.dart';
import '../../domain/entities/recommended_course_entity.dart';

class RecommendedCourseModel extends RecommendedCourseEntity {
  const RecommendedCourseModel({
    required super.course,
    required super.score,
    required super.reason,
  });

  factory RecommendedCourseModel.fromJson(Map<String, dynamic> json) {
    return RecommendedCourseModel(
      course: CourseModel.fromJson(
        json['course'] as Map<String, dynamic>? ?? {},
      ),
      score: (json['score'] as num?)?.toInt() ?? 0,
      reason: json['reason']?.toString() ?? '',
    );
  }
}
