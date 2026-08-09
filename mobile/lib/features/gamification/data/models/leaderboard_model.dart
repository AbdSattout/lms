import '../../domain/entities/leaderboard_entity.dart';

class LeaderboardEntryModel extends LeaderboardEntryEntity {
  const LeaderboardEntryModel({
    required super.rank,
    required super.userId,
    required super.name,
    super.picture,
    required super.xp,
    super.levelNumber,
    super.levelTitle,
  });

  factory LeaderboardEntryModel.fromJson(Object? json) {
    final map = _readMap(json);

    return LeaderboardEntryModel(
      rank: _readNullableInt(map['rank']),
      userId: _readInt(map['userId']),
      name: _readString(map['name']),
      picture: _readNullableString(map['picture']),
      xp: _readInt(map['xp']),
      levelNumber: _readNullableInt(map['levelNumber']),
      levelTitle: _readNullableString(map['levelTitle']),
    );
  }
}

class LeaderboardModel extends LeaderboardEntity {
  const LeaderboardModel({
    required super.period,
    super.from,
    super.to,
    required super.leaders,
    super.me,
  });

  factory LeaderboardModel.fromJson(Object? json) {
    final map = _readMap(json);
    final leadersJson = map['leaders'];
    final leaders = leadersJson is List
        ? leadersJson.map(LeaderboardEntryModel.fromJson).toList()
        : const <LeaderboardEntryModel>[];

    return LeaderboardModel(
      period: _readString(map['period']),
      from: _readNullableString(map['from']),
      to: _readNullableString(map['to']),
      leaders: leaders,
      me: map['me'] == null ? null : LeaderboardEntryModel.fromJson(map['me']),
    );
  }
}

Map<String, dynamic> _readMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  return const <String, dynamic>{};
}

int _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _readNullableInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

String _readString(Object? value) {
  return value?.toString().trim() ?? '';
}

String? _readNullableString(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty || text.toLowerCase() == 'null'
      ? null
      : text;
}
