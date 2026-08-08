class BillingUserEntity {
  final int id;
  final String name;
  final String username;
  final String picture;
  final String? email;
  final BillingPlanEntity? plan;
  final BillingSubscriptionEntity? subscription;

  const BillingUserEntity({
    required this.id,
    required this.name,
    required this.username,
    required this.picture,
    required this.email,
    required this.plan,
    required this.subscription,
  });

  bool get isSubscriptionRevoked {
    return subscription?.isRevokedOrCanceled ?? false;
  }

  bool get isPremium {
    final planIsPremium = plan?.premium ?? false;
    if (!planIsPremium) return false;

    final currentSubscription = subscription;
    if (currentSubscription == null) return true;

    return currentSubscription.isActiveEntitlement;
  }
}

class BillingPlanEntity {
  final int planId;
  final String code;
  final String name;
  final bool premium;
  final double? xpMultiplier;
  final int? weeklyAiQuizLimit;
  final int? weeklyCourseEnrollmentLimit;
  final int? activeRoadmapFollowLimit;
  final int? randomQuizPerCourseLimit;
  final int? organizationStorageLimitBytes;
  final int? organizationLimit;
  final int? organizationCourseLimit;
  final int? dailyAiToolLimit;
  final DateTime? startedAt;
  final DateTime? expiresAt;

  const BillingPlanEntity({
    required this.planId,
    required this.code,
    required this.name,
    required this.premium,
    required this.xpMultiplier,
    required this.weeklyAiQuizLimit,
    required this.weeklyCourseEnrollmentLimit,
    required this.activeRoadmapFollowLimit,
    required this.randomQuizPerCourseLimit,
    required this.organizationStorageLimitBytes,
    required this.organizationLimit,
    required this.organizationCourseLimit,
    required this.dailyAiToolLimit,
    required this.startedAt,
    required this.expiresAt,
  });
}

class BillingSubscriptionEntity {
  final String status;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final DateTime? canceledAt;
  final DateTime? revokedAt;
  final int? daysLeft;

  const BillingSubscriptionEntity({
    required this.status,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    required this.cancelAtPeriodEnd,
    required this.canceledAt,
    required this.revokedAt,
    required this.daysLeft,
  });

  bool get isRevoked => revokedAt != null;

  bool get isCanceledStatus {
    final normalized = status.trim().toLowerCase();
    return normalized == 'canceled' || normalized == 'cancelled';
  }

  bool get isRevokedOrCanceled => isRevoked || isCanceledStatus;

  bool get isActiveEntitlement => !isRevokedOrCanceled;
}
