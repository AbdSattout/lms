import '../../../courses/data/models/course_model.dart';
import '../../domain/entities/roadmap_item_entity.dart';

class RoadmapItemModel extends RoadmapItemEntity {
  const RoadmapItemModel({
    required super.id,
    required super.position,
    required super.course,
  });

  factory RoadmapItemModel.fromJson(Map<String, dynamic> json) {
    return RoadmapItemModel(
      id: json['id'] as int,
      position: json['position'] as int,
      course: CourseModel.fromJson(json['course'] as Map<String, dynamic>),
    );
  }
}