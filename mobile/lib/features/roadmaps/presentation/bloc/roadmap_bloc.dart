import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/api_error_resolver.dart';
import '../../domain/usecases/get_my_roadmaps_usecase.dart';
import '../../domain/usecases/get_organization_roadmaps_usecase.dart';
import '../../domain/usecases/get_roadmap_details_usecase.dart';
import '../../domain/usecases/follow_roadmap_usecase.dart';
import '../../domain/usecases/unfollow_roadmap_usecase.dart';
import 'roadmap_event.dart';
import 'roadmap_state.dart';

class RoadmapBloc extends Bloc<RoadmapEvent, RoadmapState> {
  final GetOrganizationRoadmapsUseCase getOrganizationRoadmaps;
  final GetRoadmapDetailsUseCase getRoadmapDetails;
  final FollowRoadmapUseCase followRoadmap;
  final UnfollowRoadmapUseCase unfollowRoadmap;
  final GetMyRoadmapsUseCase getMyRoadmaps;

  RoadmapBloc({
    required this.getOrganizationRoadmaps,
    required this.getRoadmapDetails,
    required this.followRoadmap,
    required this.unfollowRoadmap,
    required this.getMyRoadmaps,
  }) : super(RoadmapInitial()) {
    on<LoadOrganizationRoadmaps>(_onLoadOrganizationRoadmaps);
    on<LoadRoadmapDetails>(_onLoadRoadmapDetails);
    on<FollowRoadmapRequested>(_onFollow);
    on<UnfollowRoadmapRequested>(_onUnfollow);
    on<LoadMyRoadmaps>(_onLoadMyRoadmaps);
  }

  Future<void> _onLoadMyRoadmaps(
      LoadMyRoadmaps event,
      Emitter<RoadmapState> emit,
      ) async {
    try {
      emit(RoadmapLoading());
      final roadmaps = await getMyRoadmaps();
      emit(RoadmapsLoaded(roadmaps));
    } catch (e) {
      emit(RoadmapError(resolveApiErrorMessage(e)));
    }
  }

  Future<void> _onLoadOrganizationRoadmaps(
      LoadOrganizationRoadmaps event,
      Emitter<RoadmapState> emit,
      ) async {
    try {
      emit(RoadmapLoading());
      final roadmaps = await getOrganizationRoadmaps(event.slug);
      emit(RoadmapsLoaded(roadmaps));
    } catch (e) {
      emit(RoadmapError(resolveApiErrorMessage(e)));
    }
  }

  Future<void> _onLoadRoadmapDetails(
      LoadRoadmapDetails event,
      Emitter<RoadmapState> emit,
      ) async {
    try {
      emit(RoadmapLoading());
      final roadmap = await getRoadmapDetails(event.slug, event.roadmapId);
      emit(RoadmapDetailsLoaded(roadmap: roadmap));
    } catch (e) {
      emit(RoadmapError(resolveApiErrorMessage(e)));
    }
  }

  Future<void> _onFollow(
      FollowRoadmapRequested event,
      Emitter<RoadmapState> emit,
      ) async {
    try {
      emit(RoadmapDetailsLoaded(roadmap: (state as RoadmapDetailsLoaded).roadmap, isProcessing: true));
      final updated = await followRoadmap(event.slug, event.roadmapId);
      emit(RoadmapDetailsLoaded(roadmap: updated));
    } catch (e) {
      emit(RoadmapError(resolveApiErrorMessage(e)));
    }
  }

  Future<void> _onUnfollow(
      UnfollowRoadmapRequested event,
      Emitter<RoadmapState> emit,
      ) async {
    try {
      emit(RoadmapDetailsLoaded(roadmap: (state as RoadmapDetailsLoaded).roadmap, isProcessing: true));
      await unfollowRoadmap(event.slug, event.roadmapId);
      final updated = await getRoadmapDetails(event.slug, event.roadmapId);
      emit(RoadmapDetailsLoaded(roadmap: updated));
    } catch (e) {
      emit(RoadmapError(resolveApiErrorMessage(e)));
    }
  }
}