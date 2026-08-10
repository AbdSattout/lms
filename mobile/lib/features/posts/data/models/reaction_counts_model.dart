import '../../domain/entities/reaction_counts_entity.dart';

class ReactionCountsModel extends ReactionCountsEntity {
  const ReactionCountsModel({
    required super.like,
    required super.love,
    required super.support,
    required super.celebrate,
    required super.insightful,
  });

  factory ReactionCountsModel.fromJson(Map<String, dynamic> json) {
    return ReactionCountsModel(
      like: json['LIKE'] as int? ?? 0,
      love: json['LOVE'] as int? ?? 0,
      support: json['SUPPORT'] as int? ?? 0,
      celebrate: json['CELEBRATE'] as int? ?? 0,
      insightful: json['INSIGHTFUL'] as int? ?? 0,
    );
  }
}