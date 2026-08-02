ALTER TABLE organization_bans
    ADD COLUMN IF NOT EXISTS expires_at timestamp(6);

ALTER TABLE organization_moderation
    ADD COLUMN IF NOT EXISTS expires_at timestamp(6);

ALTER TABLE user_moderation
    ADD COLUMN IF NOT EXISTS expires_at timestamp(6);

CREATE INDEX IF NOT EXISTS idx_organization_bans_active_lookup
    ON organization_bans(organization_id, user_id, expires_at);

CREATE INDEX IF NOT EXISTS idx_organization_moderation_active_lookup
    ON organization_moderation(organization_id, expires_at);

CREATE INDEX IF NOT EXISTS idx_user_moderation_active_lookup
    ON user_moderation(user_id, expires_at);
