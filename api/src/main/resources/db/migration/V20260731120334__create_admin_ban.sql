CREATE TABLE course_moderation (
                                   id bigserial PRIMARY KEY,

                                   course_id bigint NOT NULL,
                                   banned_by_id bigint NOT NULL,

                                   reason text,

                                   created_at timestamp(6),
                                   updated_at timestamp(6),

                                   CONSTRAINT fk_course_moderation_course
                                       FOREIGN KEY (course_id)
                                           REFERENCES courses(id)
                                           ON DELETE CASCADE,

                                   CONSTRAINT fk_course_moderation_admin
                                       FOREIGN KEY (banned_by_id)
                                           REFERENCES admins(id)
                                           ON DELETE RESTRICT
);

CREATE INDEX idx_course_moderation_course
    ON course_moderation(course_id);

CREATE INDEX idx_course_moderation_admin
    ON course_moderation(banned_by_id);

CREATE TABLE course_bans (
                             id bigserial PRIMARY KEY,

                             course_id bigint NOT NULL,
                             user_id bigint NOT NULL,

                             banned_by_app_admins_id bigint,
                             banned_by_org_admins_id bigint,

                             reason text,

                             created_at timestamp(6),
                             updated_at timestamp(6),

                             CONSTRAINT uk_course_bans_course_user
                                 UNIQUE (course_id, user_id),

                             CONSTRAINT fk_course_bans_course
                                 FOREIGN KEY (course_id)
                                     REFERENCES courses(id)
                                     ON DELETE CASCADE,

                             CONSTRAINT fk_course_bans_user
                                 FOREIGN KEY (user_id)
                                     REFERENCES users(id)
                                     ON DELETE CASCADE,

                             CONSTRAINT fk_course_bans_app_admin
                                 FOREIGN KEY (banned_by_app_admins_id)
                                     REFERENCES admins(id)
                                     ON DELETE SET NULL,

                             CONSTRAINT fk_course_bans_org_admin
                                 FOREIGN KEY (banned_by_org_admins_id)
                                     REFERENCES users(id)
                                     ON DELETE SET NULL
);

CREATE INDEX idx_course_bans_course
    ON course_bans(course_id);

CREATE INDEX idx_course_bans_user
    ON course_bans(user_id);

CREATE TABLE organization_moderation (
                                         id bigserial PRIMARY KEY,

                                         organization_id bigint NOT NULL,
                                         banned_by_id bigint NOT NULL,

                                         reason text,

                                         created_at timestamp(6),
                                         updated_at timestamp(6),

                                         CONSTRAINT fk_organization_moderation_organization
                                             FOREIGN KEY (organization_id)
                                                 REFERENCES organizations(id)
                                                 ON DELETE CASCADE,

                                         CONSTRAINT fk_organization_moderation_admin
                                             FOREIGN KEY (banned_by_id)
                                                 REFERENCES admins(id)
                                                 ON DELETE RESTRICT
);

CREATE INDEX idx_organization_moderation_organization
    ON organization_moderation(organization_id);

CREATE INDEX idx_organization_moderation_admin
    ON organization_moderation(banned_by_id);

CREATE TABLE organization_bans (
                                   id bigserial PRIMARY KEY,

                                   organization_id bigint NOT NULL,
                                   user_id bigint NOT NULL,

                                   banned_by_app_admins_id bigint,
                                   banned_by_org_admins_id bigint,

                                   reason text,

                                   created_at timestamp(6),
                                   updated_at timestamp(6),

                                   CONSTRAINT uk_organization_bans_organization_user
                                       UNIQUE (organization_id, user_id),

                                   CONSTRAINT fk_organization_bans_organization
                                       FOREIGN KEY (organization_id)
                                           REFERENCES organizations(id)
                                           ON DELETE CASCADE,

                                   CONSTRAINT fk_organization_bans_user
                                       FOREIGN KEY (user_id)
                                           REFERENCES users(id)
                                           ON DELETE CASCADE,

                                   CONSTRAINT fk_organization_bans_app_admin
                                       FOREIGN KEY (banned_by_app_admins_id)
                                           REFERENCES admins(id)
                                           ON DELETE SET NULL,

                                   CONSTRAINT fk_organization_bans_org_admin
                                       FOREIGN KEY (banned_by_org_admins_id)
                                           REFERENCES users(id)
                                           ON DELETE SET NULL
);

CREATE INDEX idx_organization_bans_organization
    ON organization_bans(organization_id);

CREATE INDEX idx_organization_bans_user
    ON organization_bans(user_id);