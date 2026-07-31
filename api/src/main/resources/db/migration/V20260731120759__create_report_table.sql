CREATE TABLE reports (
                         id bigserial PRIMARY KEY,

                         reporter_id bigint NOT NULL,
                         reviewed_by_id bigint,

                         target_type varchar(255) NOT NULL,
                         target_id bigint NOT NULL,

                         reason text,

                         status varchar(255) NOT NULL DEFAULT 'PENDING',

                         admin_note varchar(1000),

                         reviewed_at timestamp(6),

                         created_at timestamp(6),
                         updated_at timestamp(6),

                         CONSTRAINT fk_reports_reporter
                             FOREIGN KEY (reporter_id)
                                 REFERENCES users(id)
                                 ON DELETE CASCADE,

                         CONSTRAINT fk_reports_reviewed_by
                             FOREIGN KEY (reviewed_by_id)
                                 REFERENCES admins(id)
                                 ON DELETE SET NULL
);

CREATE INDEX idx_reports_reporter
    ON reports(reporter_id);

CREATE INDEX idx_reports_reviewed_by
    ON reports(reviewed_by_id);

CREATE INDEX idx_reports_target
    ON reports(target_type, target_id);

CREATE INDEX idx_reports_status
    ON reports(status);