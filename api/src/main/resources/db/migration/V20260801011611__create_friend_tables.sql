CREATE TABLE friend_requests (
                                 id bigserial PRIMARY KEY,

                                 sender_id bigint NOT NULL,
                                 receiver_id bigint NOT NULL,

                                 status varchar(255) NOT NULL,

                                 responded_at timestamp(6),

                                 created_at timestamp(6),
                                 updated_at timestamp(6),

                                 CONSTRAINT uk_friend_requests_sender_receiver
                                     UNIQUE (sender_id, receiver_id),

                                 CONSTRAINT fk_friend_requests_sender
                                     FOREIGN KEY (sender_id)
                                         REFERENCES users(id)
                                         ON DELETE CASCADE,

                                 CONSTRAINT fk_friend_requests_receiver
                                     FOREIGN KEY (receiver_id)
                                         REFERENCES users(id)
                                         ON DELETE CASCADE
);

CREATE INDEX idx_friend_requests_sender
    ON friend_requests(sender_id);

CREATE INDEX idx_friend_requests_receiver
    ON friend_requests(receiver_id);

CREATE INDEX idx_friend_requests_status
    ON friend_requests(status);

CREATE TABLE friends (
                         id bigserial PRIMARY KEY,

                         user1_id bigint NOT NULL,
                         user2_id bigint NOT NULL,

                         created_at timestamp(6),
                         updated_at timestamp(6),

                         CONSTRAINT uk_friends_user1_user2
                             UNIQUE (user1_id, user2_id),

                         CONSTRAINT fk_friends_user1
                             FOREIGN KEY (user1_id)
                                 REFERENCES users(id)
                                 ON DELETE CASCADE,

                         CONSTRAINT fk_friends_user2
                             FOREIGN KEY (user2_id)
                                 REFERENCES users(id)
                                 ON DELETE CASCADE
);

CREATE INDEX idx_friends_user1
    ON friends(user1_id);

CREATE INDEX idx_friends_user2
    ON friends(user2_id);