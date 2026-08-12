import '../../domain/entities/roadmap_entity.dart';

abstract class RoadmapState {}

class RoadmapInitial extends RoadmapState {}

class RoadmapLoading extends RoadmapState {}

class RoadmapsLoaded extends RoadmapState {
  final List<RoadmapEntity> roadmaps;
  RoadmapsLoaded(this.roadmaps);
}

class RoadmapDetailsLoaded extends RoadmapState {
  final RoadmapEntity roadmap;
  final bool isProcessing;
  RoadmapDetailsLoaded({required this.roadmap, this.isProcessing = false});
}

class RoadmapError extends RoadmapState {
  final String message;
  RoadmapError(this.message);
}