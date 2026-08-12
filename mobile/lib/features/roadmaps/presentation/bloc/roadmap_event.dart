abstract class RoadmapEvent {}
class LoadMyRoadmaps extends RoadmapEvent {}
class LoadOrganizationRoadmaps extends RoadmapEvent {
  final String slug;
  LoadOrganizationRoadmaps(this.slug);
}

class LoadRoadmapDetails extends RoadmapEvent {
  final String slug;
  final int roadmapId;
  LoadRoadmapDetails({required this.slug, required this.roadmapId});
}

class FollowRoadmapRequested extends RoadmapEvent {
  final String slug;
  final int roadmapId;
  FollowRoadmapRequested({required this.slug, required this.roadmapId});
}

class UnfollowRoadmapRequested extends RoadmapEvent {
  final String slug;
  final int roadmapId;
  UnfollowRoadmapRequested({required this.slug, required this.roadmapId});
}