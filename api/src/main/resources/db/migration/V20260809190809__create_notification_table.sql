CREATE TABLE notifications (
                               id bigserial PRIMARY KEY,

                               user_id bigint NOT NULL,

                               type varchar(255) NOT NULL,

                               title varchar(255) NOT NULL,

                               message text NOT NULL,

                               reference_type varchar(255),

                               reference_id bigint,

                               read boolean NOT NULL DEFAULT false,

                               read_at timestamp(6),

                               created_at timestamp(6),
                               updated_at timestamp(6),

                               CONSTRAINT fk_notifications_user
                                   FOREIGN KEY (user_id)
                                       REFERENCES users(id)
                                       ON DELETE CASCADE
);

CREATE INDEX idx_notifications_user
    ON notifications(user_id);

CREATE INDEX idx_notifications_user_read
    ON notifications(user_id, read);

CREATE INDEX idx_notifications_created_at
    ON notifications(created_at);

CREATE TABLE user_devices (
                              id bigserial PRIMARY KEY,

                              user_id bigint NOT NULL,

                              token varchar(255) NOT NULL,

                              active boolean NOT NULL DEFAULT true,

                              last_used_at timestamp(6),

                              created_at timestamp(6),
                              updated_at timestamp(6),

                              CONSTRAINT uk_user_devices_token
                                  UNIQUE (token),

                              CONSTRAINT fk_user_devices_user
                                  FOREIGN KEY (user_id)
                                      REFERENCES users(id)
                                      ON DELETE CASCADE
);

CREATE INDEX idx_user_devices_user
    ON user_devices(user_id);

CREATE INDEX idx_user_devices_active
    ON user_devices(active);