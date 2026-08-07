class GamificationProgressEntity {
  final int currentLevelXp;
  final int levelNumber;
  final String levelTitle;
  final int nextLevelXp;
  final double progressPercentage;
  final String tier;
  final int totalXp;
  final int xpIntoLevel;
  final int xpToNextLevel;

  const GamificationProgressEntity({
    required this.currentLevelXp,
    required this.levelNumber,
    required this.levelTitle,
    required this.nextLevelXp,
    required this.progressPercentage,
    required this.tier,
    required this.totalXp,
    required this.xpIntoLevel,
    required this.xpToNextLevel,
  });
}