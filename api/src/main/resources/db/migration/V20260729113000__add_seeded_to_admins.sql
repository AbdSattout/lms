ALTER TABLE admins
    ADD COLUMN seeded boolean NOT NULL DEFAULT false;

CREATE INDEX idx_admins_seeded
    ON admins(seeded);
