import '../../domain/entities/gamification_progress_entity.dart';

class GamificationProgressModel extends GamificationProgressEntity {
  const GamificationProgressModel({
    required super.currentLevelXp,
    required super.levelNumber,
    required super.levelTitle,
    required super.nextLevelXp,
    required super.progressPercentage,
    required super.tier,
    required super.totalXp,
    required super.xpIntoLevel,
    required super.xpToNextLevel,
  });

  factory GamificationProgressModel.fromJson(Map<String, dynamic> json) {
    return GamificationProgressModel(
      currentLevelXp: json['currentLevelXp'] ?? 0,
      levelNumber: json['levelNumber'] ?? 1,
      levelTitle: json['levelTitle'] ?? 'Beginner',
      nextLevelXp: json['nextLevelXp'] ?? 100,
      progressPercentage: (json['progressPercentage'] ?? 0).toDouble(),
      tier: json['tier'] ?? 'BEGINNER',
      totalXp: json['totalXp'] ?? 0,
      xpIntoLevel: json['xpIntoLevel'] ?? 0,
      xpToNextLevel: json['xpToNextLevel'] ?? 0,
    );
  }
}