CREATE TABLE conversations (
                               id bigserial PRIMARY KEY,

                               type varchar(255) NOT NULL,

                               course_id bigint UNIQUE,

                               direct_user_one_id bigint,
                               direct_user_two_id bigint,

                               last_message_preview varchar(500),
                               last_message_at timestamp(6),

                               created_at timestamp(6),
                               updated_at timestamp(6),

                               CONSTRAINT uk_direct_users
                                   UNIQUE (direct_user_one_id, direct_user_two_id),

                               CONSTRAINT fk_conversations_course
                                   FOREIGN KEY (course_id)
                                       REFERENCES courses(id)
                                       ON DELETE CASCADE,

                               CONSTRAINT fk_conversations_direct_user_one
                                   FOREIGN KEY (direct_user_one_id)
                                       REFERENCES users(id)
                                       ON DELETE CASCADE,

                               CONSTRAINT fk_conversations_direct_user_two
                                   FOREIGN KEY (direct_user_two_id)
                                       REFERENCES users(id)
                                       ON DELETE CASCADE
);

CREATE INDEX idx_conversations_course
    ON conversations(course_id);

CREATE INDEX idx_conversations_direct_user_one
    ON conversations(direct_user_one_id);

CREATE INDEX idx_conversations_direct_user_two
    ON conversations(direct_user_two_id);

CREATE TABLE conversation_members (
                                      id bigserial PRIMARY KEY,

                                      conversation_id bigint NOT NULL,
                                      user_id bigint NOT NULL,

                                      joined_at timestamp(6) NOT NULL,

                                      last_read_message_id bigint,
                                      last_read_at timestamp(6),

                                      created_at timestamp(6),
                                      updated_at timestamp(6),

                                      CONSTRAINT uk_conversation_member
                                          UNIQUE (conversation_id, user_id),

                                      CONSTRAINT fk_conversation_members_conversation
                                          FOREIGN KEY (conversation_id)
                                              REFERENCES conversations(id)
                                              ON DELETE CASCADE,

                                      CONSTRAINT fk_conversation_members_user
                                          FOREIGN KEY (user_id)
                                              REFERENCES users(id)
                                              ON DELETE CASCADE
);

CREATE INDEX idx_conversation_members_conversation
    ON conversation_members(conversation_id);

CREATE INDEX idx_conversation_members_user
    ON conversation_members(user_id);

CREATE INDEX idx_conversation_members_last_read
    ON conversation_members(last_read_message_id);

CREATE TABLE messages (
                          id bigserial PRIMARY KEY,

                          conversation_id bigint NOT NULL,
                          sender_id bigint NOT NULL,

                          content text NOT NULL,

                          type varchar(20) NOT NULL,

                          edited_at timestamp(6),
                          deleted_at timestamp(6),

                          created_at timestamp(6),
                          updated_at timestamp(6),

                          CONSTRAINT fk_messages_conversation
                              FOREIGN KEY (conversation_id)
                                  REFERENCES conversations(id)
                                  ON DELETE CASCADE,

                          CONSTRAINT fk_messages_sender
                              FOREIGN KEY (sender_id)
                                  REFERENCES users(id)
                                  ON DELETE CASCADE
);

CREATE INDEX idx_messages_conversation
    ON messages(conversation_id);

CREATE INDEX idx_messages_sender
    ON messages(sender_id);

CREATE INDEX idx_messages_conversation_created_at
    ON messages(conversation_id, created_at);

CREATE TABLE chat_mutes (
                            id bigserial PRIMARY KEY,

                            user_id bigint NOT NULL,

                            course_id bigint,

                            conversation_id bigint,

                            created_by_user_id bigint NOT NULL,

                            muted_until timestamp(6) NOT NULL,

                            reason varchar(500),

                            revoked_at timestamp(6),

                            created_at timestamp(6),
                            updated_at timestamp(6),

                            CONSTRAINT fk_chat_mutes_user
                                FOREIGN KEY (user_id)
                                    REFERENCES users(id)
                                    ON DELETE CASCADE,

                            CONSTRAINT fk_chat_mutes_course
                                FOREIGN KEY (course_id)
                                    REFERENCES courses(id)
                                    ON DELETE CASCADE,

                            CONSTRAINT fk_chat_mutes_conversation
                                FOREIGN KEY (conversation_id)
                                    REFERENCES conversations(id)
                                    ON DELETE CASCADE,

                            CONSTRAINT fk_chat_mutes_created_by
                                FOREIGN KEY (created_by_user_id)
                                    REFERENCES users(id)
                                    ON DELETE CASCADE
);

CREATE INDEX idx_chat_mutes_user
    ON chat_mutes(user_id);

CREATE INDEX idx_chat_mutes_course
    ON chat_mutes(course_id);

CREATE INDEX idx_chat_mutes_conversation
    ON chat_mutes(conversation_id);

CREATE INDEX idx_chat_mutes_active
    ON chat_mutes(user_id, muted_until, revoked_at);