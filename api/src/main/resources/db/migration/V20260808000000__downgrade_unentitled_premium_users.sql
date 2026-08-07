WITH free_plan AS (
    SELECT id
    FROM plans
    WHERE code = 'FREE'
),
premium_plan AS (
    SELECT id
    FROM plans
    WHERE code = 'PREMIUM'
),
active_polar_users AS (
    SELECT DISTINCT user_id
    FROM polar_subscriptions
    WHERE revoked_at IS NULL
      AND status IN ('active', 'trialing', 'past_due', 'canceled')
      AND (
          current_period_end IS NULL
          OR current_period_end > NOW()
      )
),
active_award_users AS (
    SELECT DISTINCT user_id
    FROM monthly_scoreboard_premium_awards
    WHERE premium_started_at <= NOW()
      AND premium_expires_at > NOW()
),
users_to_downgrade AS (
    SELECT up.user_id
    FROM user_plans up
    JOIN premium_plan pp ON pp.id = up.plan_id
    WHERE NOT EXISTS (
        SELECT 1
        FROM active_polar_users apu
        WHERE apu.user_id = up.user_id
    )
      AND NOT EXISTS (
        SELECT 1
        FROM active_award_users aau
        WHERE aau.user_id = up.user_id
    )
),
downgraded_users AS (
    UPDATE user_plans up
    SET plan_id = fp.id,
        started_at = NOW(),
        expires_at = NULL,
        canceled_at = NULL,
        updated_at = NOW()
    FROM free_plan fp,
         users_to_downgrade utd
    WHERE up.user_id = utd.user_id
    RETURNING up.user_id
)
UPDATE polar_subscriptions ps
SET status = 'revoked',
    cancel_at_period_end = false,
    canceled_at = COALESCE(canceled_at, NOW()),
    revoked_at = COALESCE(revoked_at, NOW()),
    updated_at = NOW()
WHERE ps.user_id IN (
    SELECT user_id
    FROM downgraded_users
)
  AND ps.revoked_at IS NULL;
