import '../../../courses/domain/entities/course_entity.dart';

class RoadmapItemEntity {
  final int id;
  final int position;
  final CourseEntity course;

  const RoadmapItemEntity({
    required this.id,
    required this.position,
    required this.course,
  });
}