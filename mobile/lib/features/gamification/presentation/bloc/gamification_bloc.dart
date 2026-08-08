import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/api_error_resolver.dart';
import '../../domain/usecases/get_my_progress_usecase.dart';
import '../../domain/usecases/get_my_streak_usecase.dart';
import '../../domain/usecases/get_activity_usecase.dart';
import '../../domain/usecases/get_leaderboard_usecase.dart';
import 'gamification_event.dart';
import 'gamification_state.dart';

class GamificationBloc extends Bloc<GamificationEvent, GamificationState> {
  final GetMyProgressUseCase getMyProgress;
  final GetMyStreakUseCase getMyStreak;
  final GetActivityUseCase getActivity;
  final GetLeaderboardUseCase getLeaderboard;

  GamificationBloc({
    required this.getMyProgress,
    required this.getMyStreak,
    required this.getActivity,
    required this.getLeaderboard,
  }) : super(GamificationInitial()) {
    on<LoadGamificationData>(_onLoadData);
    on<LoadLeaderboard>(_onLoadLeaderboard);
  }

  Future<void> _onLoadData(
      LoadGamificationData event,
      Emitter<GamificationState> emit,
      ) async {
    try {
      emit(GamificationLoading());
      final results = await Future.wait([
        getMyProgress(),
        getMyStreak(),
        getActivity(),
      ]);
      emit(GamificationLoaded(
        progress: results[0] as dynamic,
        streak: results[1] as dynamic,
        activities: results[2] as dynamic,
      ));
    } catch (e) {
      emit(GamificationError(resolveApiErrorMessage(e)));
    }
  }

  Future<void> _onLoadLeaderboard(
      LoadLeaderboard event,
      Emitter<GamificationState> emit,
      ) async {
    try {
      emit(GamificationLoading());
      final leaderboard = await getLeaderboard(
        period: event.period,
        limit: event.limit,
      );
      emit(LeaderboardLoaded(leaderboard));
    } catch (e) {
      emit(GamificationError(resolveApiErrorMessage(e)));
    }
  }
}