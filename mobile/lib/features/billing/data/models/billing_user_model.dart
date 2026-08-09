import '../../domain/entities/billing_user_entity.dart';

class BillingUserModel extends BillingUserEntity {
  const BillingUserModel({
    required super.id,
    required super.name,
    required super.username,
    required super.picture,
    required super.email,
    required super.plan,
    required super.subscription,
  });

  factory BillingUserModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};

    return BillingUserModel(
      id: _readInt(map['id']),
      name: _readString(map['name']),
      username: _readString(map['username']),
      picture: _readString(map['picture']),
      email: _readNullableString(map['email']),
      plan: BillingPlanModel.fromJsonOrNull(map['plan']),
      subscription: BillingSubscriptionModel.fromJsonOrNull(
        map['subscription'],
      ),
    );
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _readString(Object? value) {
    return value?.toString().trim() ?? '';
  }

  static String? _readNullableString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}

class BillingPlanModel extends BillingPlanEntity {
  const BillingPlanModel({
    required super.planId,
    required super.code,
    required super.name,
    required super.premium,
    required super.xpMultiplier,
    required super.weeklyAiQuizLimit,
    required super.weeklyCourseEnrollmentLimit,
    required super.activeRoadmapFollowLimit,
    required super.randomQuizPerCourseLimit,
    required super.organizationStorageLimitBytes,
    required super.organizationLimit,
    required super.organizationCourseLimit,
    required super.dailyAiToolLimit,
    required super.startedAt,
    required super.expiresAt,
  });

  factory BillingPlanModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};

    return BillingPlanModel(
      planId: _readInt(map['planId']),
      code: _readString(map['code']),
      name: _readString(map['name']),
      premium: _readBool(map['premium']),
      xpMultiplier: _readDouble(map['xpMultiplier']),
      weeklyAiQuizLimit: _readNullableInt(map['weeklyAiQuizLimit']),
      weeklyCourseEnrollmentLimit: _readNullableInt(
        map['weeklyCourseEnrollmentLimit'],
      ),
      activeRoadmapFollowLimit: _readNullableInt(
        map['activeRoadmapFollowLimit'],
      ),
      randomQuizPerCourseLimit: _readNullableInt(
        map['randomQuizPerCourseLimit'],
      ),
      organizationStorageLimitBytes: _readNullableInt(
        map['organizationStorageLimitBytes'],
      ),
      organizationLimit: _readNullableInt(map['organizationLimit']),
      organizationCourseLimit: _readNullableInt(map['organizationCourseLimit']),
      dailyAiToolLimit: _readNullableInt(map['dailyAiToolLimit']),
      startedAt: _readDateTime(map['startedAt']),
      expiresAt: _readDateTime(map['expiresAt']),
    );
  }

  static BillingPlanModel? fromJsonOrNull(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    return BillingPlanModel.fromJson(json);
  }
}

class BillingSubscriptionModel extends BillingSubscriptionEntity {
  const BillingSubscriptionModel({
    required super.status,
    required super.currentPeriodStart,
    required super.currentPeriodEnd,
    required super.cancelAtPeriodEnd,
    required super.canceledAt,
    required super.revokedAt,
    required super.daysLeft,
  });

  factory BillingSubscriptionModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};

    return BillingSubscriptionModel(
      status: _readString(map['status']),
      currentPeriodStart: _readDateTime(map['currentPeriodStart']),
      currentPeriodEnd: _readDateTime(map['currentPeriodEnd']),
      cancelAtPeriodEnd: _readBool(map['cancelAtPeriodEnd']),
      canceledAt: _readDateTime(map['canceledAt']),
      revokedAt: _readDateTime(map['revokedAt']),
      daysLeft: _readNullableInt(map['daysLeft']),
    );
  }

  static BillingSubscriptionModel? fromJsonOrNull(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    return BillingSubscriptionModel.fromJson(json);
  }
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

double? _readDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool _readBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value?.toString().toLowerCase() == 'true';
}

String _readString(Object? value) {
  return value?.toString().trim() ?? '';
}

DateTime? _readDateTime(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;
  return DateTime.tryParse(text);
}
