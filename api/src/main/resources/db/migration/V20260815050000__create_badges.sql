CREATE TABLE badges (
    id bigserial PRIMARY KEY,
    code varchar(100) NOT NULL,
    title varchar(255) NOT NULL,
    description varchar(500),
    icon_url text,
    sort_order integer NOT NULL DEFAULT 0,
    active boolean NOT NULL DEFAULT true,
    created_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,

    CONSTRAINT uk_badges_code UNIQUE (code)
);

CREATE TABLE user_badges (
    id bigserial PRIMARY KEY,
    user_id bigint NOT NULL,
    badge_id bigint NOT NULL,
    earned_at timestamp(6) with time zone NOT NULL,
    created_at timestamp(6) with time zone,
    updated_at timestamp(6) with time zone,

    CONSTRAINT uk_user_badges_user_badge UNIQUE (user_id, badge_id),

    CONSTRAINT fk_user_badges_user
        FOREIGN KEY (user_id)
            REFERENCES users(id)
            ON DELETE CASCADE,

    CONSTRAINT fk_user_badges_badge
        FOREIGN KEY (badge_id)
            REFERENCES badges(id)
            ON DELETE CASCADE
);

CREATE INDEX idx_badges_active_sort_order
    ON badges(active, sort_order);

CREATE INDEX idx_user_badges_user_earned_at
    ON user_badges(user_id, earned_at DESC);

INSERT INTO badges (
    code,
    title,
    description,
    sort_order,
    active,
    created_at,
    updated_at
)
VALUES
    (
        'FIRST_STREAK',
        'First streak',
        'Recorded at least one active learning day',
        10,
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'WEEK_STREAK',
        '7-day learner',
        'Kept a learning streak for at least 7 days',
        20,
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'MONTH_STREAK',
        '30-day learner',
        'Kept a learning streak for at least 30 days',
        30,
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'COURSE_FINISHER',
        'Course finisher',
        'Completed at least one course',
        40,
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'FIVE_COURSES',
        'Committed learner',
        'Completed at least five courses',
        50,
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'CERTIFIED_LEARNER',
        'Certified learner',
        'Earned at least one certificate',
        60,
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'CONNECTED_LEARNER',
        'Connected learner',
        'Connected with at least one learner',
        70,
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'SOCIAL_LEARNER',
        'Social learner',
        'Connected with at least ten learners',
        80,
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'ROADMAP_FINISHER',
        'Roadmap finisher',
        'Completed at least one roadmap',
        90,
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'XP_1000',
        '1K XP',
        'Earned at least 1,000 XP',
        100,
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'LEVEL_5',
        'Level 5 learner',
        'Reached level 5',
        105,
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'XP_5000',
        '5K XP',
        'Earned at least 5,000 XP',
        110,
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'LEVEL_10',
        'Level 10 learner',
        'Reached level 10',
        115,
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        'LEVEL_20',
        'Level 20 learner',
        'Reached level 20',
        120,
        true,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    )
ON CONFLICT (code) DO NOTHING;
