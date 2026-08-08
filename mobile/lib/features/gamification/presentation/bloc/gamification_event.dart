abstract class GamificationEvent {}

class LoadGamificationData extends GamificationEvent {}

class LoadLeaderboard extends GamificationEvent {
  final String period;
  final int? limit;
  LoadLeaderboard({required this.period, this.limit});
}