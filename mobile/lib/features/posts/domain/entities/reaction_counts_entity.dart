class ReactionCountsEntity {
  final int like;
  final int love;
  final int support;
  final int celebrate;
  final int insightful;

  const ReactionCountsEntity({
    required this.like,
    required this.love,
    required this.support,
    required this.celebrate,
    required this.insightful,
  });

  int get total => like + love + support + celebrate + insightful;
}