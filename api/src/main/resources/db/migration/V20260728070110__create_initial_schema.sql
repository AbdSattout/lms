CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE TABLE users (
                       id bigserial PRIMARY KEY,
                       name varchar(255),
                       username varchar(255),
                       picture varchar(255),
                       picture_file_id varchar(255),
                       telegram_id varchar(255) NOT NULL UNIQUE
);

CREATE TABLE plans (
                       id bigserial PRIMARY KEY,
                       code varchar(255) NOT NULL UNIQUE,
                       name varchar(255) NOT NULL,
                       description varchar(255),
                       default_plan boolean NOT NULL DEFAULT false,
                       xp_multiplier numeric(4, 2) NOT NULL DEFAULT 1,
                       weekly_ai_quiz_limit integer,
                       weekly_course_enrollment_limit integer,
                       active_roadmap_follow_limit integer,
                       random_quiz_per_course_limit integer,
                       organization_storage_limit_bytes bigint,
                       organization_limit integer,
                       daily_ai_tool_limit integer,
                       created_at timestamp(6),
                       updated_at timestamp(6)
);

CREATE TABLE levels (
                        id bigserial PRIMARY KEY,
                        level_number integer NOT NULL UNIQUE,
                        required_xp integer NOT NULL,
                        title varchar(255) NOT NULL,
                        tier varchar(255) NOT NULL,
                        created_at timestamp(6),
                        updated_at timestamp(6)
);

CREATE TABLE profiles (
                          id bigserial PRIMARY KEY,
                          email varchar(255),
                          phone varchar(255),
                          university varchar(255),
                          user_id bigint NOT NULL UNIQUE
);

CREATE TABLE user_plans (
                            id bigserial PRIMARY KEY,
                            user_id bigint NOT NULL UNIQUE,
                            plan_id bigint NOT NULL,
                            started_at timestamp(6) NOT NULL,
                            expires_at timestamp(6),
                            canceled_at timestamp(6),
                            created_at timestamp(6),
                            updated_at timestamp(6)
);

CREATE TABLE user_progress (
                               id bigserial PRIMARY KEY,
                               user_id bigint NOT NULL UNIQUE,
                               total_xp integer NOT NULL,
                               current_level_id bigint,
                               created_at timestamp(6),
                               updated_at timestamp(6)
);

CREATE TABLE user_activity_days (
                                    id bigserial PRIMARY KEY,
                                    user_id bigint NOT NULL,
                                    activity_date date NOT NULL,
                                    xp_earned integer NOT NULL,
                                    completed_blocks integer NOT NULL,
                                    completed_lessons integer NOT NULL,
                                    completed_chapters integer NOT NULL,
                                    completed_courses integer NOT NULL,
                                    completed_practice_quizzes integer NOT NULL,
                                    completed_final_quizzes integer NOT NULL,
                                    completed_quizzes integer NOT NULL,
                                    correct_questions integer NOT NULL,
                                    enrollments integer NOT NULL,
                                    created_at timestamp(6),
                                    updated_at timestamp(6),
                                    CONSTRAINT uk_user_activity_days_user_date UNIQUE (user_id, activity_date)
);

CREATE TABLE xp_events (
                           id bigserial PRIMARY KEY,
                           type varchar(255),
                           reference_id bigint,
                           amount integer,
                           user_id bigint,
                           created_at timestamp(6),
                           updated_at timestamp(6)
);

CREATE TABLE organizations (
                               id bigserial PRIMARY KEY,
                               name varchar(255) NOT NULL UNIQUE,
                               slug varchar(255) NOT NULL UNIQUE,
                               description varchar(255),
                               image_url varchar(255),
                               image_file_id varchar(255),
                               visibility varchar(255) NOT NULL,
                               owner_id bigint,
                               created_at timestamp(6),
                               updated_at timestamp(6)
);

CREATE TABLE organization_members (
                                      id bigserial PRIMARY KEY,
                                      organization_id bigint,
                                      user_id bigint,
                                      role varchar(255),
                                      joined_at timestamp(6),
                                      UNIQUE (organization_id, user_id)
);

CREATE TABLE organization_invites (
                                      id bigserial PRIMARY KEY,
                                      organization_id bigint,
                                      user_id bigint,
                                      role varchar(255),
                                      token varchar(255) NOT NULL UNIQUE,
                                      invited_by bigint,
                                      status varchar(255),
                                      max_uses integer,
                                      used_count integer NOT NULL DEFAULT 0,
                                      expires_at timestamp(6),
                                      accepted_at timestamp(6),
                                      created_at timestamp(6),
                                      updated_at timestamp(6)
);

CREATE TABLE organization_join_requests (
                                            id bigserial PRIMARY KEY,
                                            organization_id bigint NOT NULL,
                                            user_id bigint NOT NULL,
                                            status varchar(255) NOT NULL,
                                            created_at timestamp(6) NOT NULL,
                                            reviewed_at timestamp(6),
                                            reviewed_by_id bigint
);

CREATE TABLE courses (
                         id bigserial PRIMARY KEY,
                         title varchar(255) NOT NULL,
                         slug varchar(255) NOT NULL,
                         cover_url varchar(255),
                         cover_file_id varchar(255),
                         description varchar(255),
                         organization_id bigint,
                         status varchar(255) NOT NULL,
                         created_at timestamp(6),
                         updated_at timestamp(6),
                         UNIQUE (organization_id, slug)
);

CREATE TABLE organization_media (
                                    id bigserial PRIMARY KEY,
                                    name varchar(255) NOT NULL,
                                    url text NOT NULL,
                                    file_id varchar(255) NOT NULL,
                                    type varchar(255) NOT NULL,
                                    size_bytes bigint NOT NULL,
                                    organization_id bigint NOT NULL,
                                    created_at timestamp(6),
                                    updated_at timestamp(6),
                                    CONSTRAINT uk_organization_media_organization_name UNIQUE (organization_id, name)
);

CREATE TABLE course_media (
                              id bigserial PRIMARY KEY,
                              course_id bigint NOT NULL,
                              organization_media_id bigint,
                              created_at timestamp(6),
                              updated_at timestamp(6),
                              CONSTRAINT uk_course_media_course_organization_media UNIQUE (course_id, organization_media_id)
);

CREATE TABLE post_media (
                            id bigserial PRIMARY KEY,
                            organization_id bigint NOT NULL,
                            organization_media_id bigint,
                            created_at timestamp(6),
                            updated_at timestamp(6),
                            UNIQUE (organization_id, organization_media_id)
);

CREATE TABLE chapters (
                          id bigserial PRIMARY KEY,
                          title varchar(255) NOT NULL,
                          position integer,
                          course_id bigint NOT NULL,
                          created_at timestamp(6),
                          updated_at timestamp(6)
);

CREATE TABLE lessons (
                         id bigserial PRIMARY KEY,
                         title varchar(255) NOT NULL,
                         position integer,
                         chapter_id bigint,
                         created_at timestamp(6),
                         updated_at timestamp(6)
);

CREATE TABLE questions (
                           id bigserial PRIMARY KEY,
                           content text NOT NULL,
                           correct_answer_index integer NOT NULL,
                           difficulty varchar(255) NOT NULL,
                           course_id bigint NOT NULL,
                           created_at timestamp(6),
                           updated_at timestamp(6)
);

CREATE TABLE question_options (
                                  question_id bigint NOT NULL,
                                  option_value varchar(255) NOT NULL
);

CREATE TABLE blocks (
                        id bigserial PRIMARY KEY,
                        title varchar(255),
                        content text,
                        position integer,
                        lesson_id bigint NOT NULL,
                        question_id bigint NOT NULL,
                        created_at timestamp(6),
                        updated_at timestamp(6)
);

CREATE TABLE quizzes (
                         id bigserial PRIMARY KEY,
                         title varchar(255),
                         course_id bigint NOT NULL UNIQUE,
                         created_at timestamp(6),
                         updated_at timestamp(6)
);

CREATE TABLE quiz_questions (
                                quiz_id bigint NOT NULL,
                                question_id bigint NOT NULL,
                                position integer NOT NULL,
                                PRIMARY KEY (quiz_id, position)
);

CREATE TABLE practice_quizzes (
                                  id bigserial PRIMARY KEY,
                                  title varchar(255) NOT NULL,
                                  description text,
                                  course_id bigint NOT NULL,
                                  created_at timestamp(6),
                                  updated_at timestamp(6)
);

CREATE TABLE practice_quiz_questions (
                                         practice_quiz_id bigint NOT NULL,
                                         question_id bigint NOT NULL,
                                         position integer NOT NULL,
                                         PRIMARY KEY (practice_quiz_id, position)
);

CREATE TABLE practice_exams (
                                id bigserial PRIMARY KEY,
                                title varchar(255) NOT NULL,
                                description text,
                                course_id bigint NOT NULL,
                                created_at timestamp(6),
                                updated_at timestamp(6)
);

CREATE TABLE practice_exam_questions (
                                         practice_exam_id bigint NOT NULL,
                                         question_id bigint NOT NULL,
                                         position integer NOT NULL,
                                         PRIMARY KEY (practice_exam_id, position)
);

CREATE TABLE course_enrollments (
                                    id bigserial PRIMARY KEY,
                                    user_id bigint NOT NULL,
                                    course_id bigint NOT NULL,
                                    enrolled_at timestamp(6),
                                    status varchar(255) NOT NULL,
                                    progress_percentage integer,
                                    current_lesson_id bigint,
                                    current_block_id bigint,
                                    completed_at timestamp(6),
                                    UNIQUE (user_id, course_id)
);

CREATE TABLE block_progress (
                                id bigserial PRIMARY KEY,
                                attempts integer,
                                completed boolean,
                                user_id bigint NOT NULL,
                                block_id bigint NOT NULL,
                                created_at timestamp(6),
                                updated_at timestamp(6),
                                UNIQUE (user_id, block_id)
);

CREATE TABLE course_faqs (
                             id bigserial PRIMARY KEY,
                             question text NOT NULL,
                             answer text NOT NULL,
                             position integer NOT NULL,
                             course_id bigint NOT NULL,
                             created_at timestamp(6),
                             updated_at timestamp(6)
);

CREATE TABLE certificates (
                              id bigserial PRIMARY KEY,
                              code varchar(255) NOT NULL UNIQUE,
                              user_id bigint NOT NULL,
                              course_id bigint NOT NULL,
                              final_quiz_score integer NOT NULL,
                              final_quiz_total integer NOT NULL,
                              final_quiz_percentage integer NOT NULL,
                              grade varchar(255) NOT NULL,
                              created_at timestamp(6),
                              updated_at timestamp(6),
                              UNIQUE (user_id, course_id)
);

CREATE TABLE roadmaps (
                          id bigserial PRIMARY KEY,
                          organization_id bigint NOT NULL,
                          created_at timestamp(6),
                          updated_at timestamp(6)
);

CREATE TABLE roadmap_items (
                               id bigserial PRIMARY KEY,
                               roadmap_id bigint NOT NULL,
                               course_id bigint NOT NULL,
                               position integer NOT NULL,
                               created_at timestamp(6),
                               updated_at timestamp(6),
                               UNIQUE (roadmap_id, course_id)
);

CREATE TABLE roadmap_followers (
                                   id bigserial PRIMARY KEY,
                                   roadmap_id bigint NOT NULL,
                                   user_id bigint NOT NULL,
                                   status varchar(255) NOT NULL DEFAULT 'ACTIVE',
                                   created_at timestamp(6),
                                   updated_at timestamp(6),
                                   UNIQUE (roadmap_id, user_id)
);

CREATE TABLE posts (
                       id bigserial PRIMARY KEY,
                       title varchar(500) NOT NULL,
                       content varchar(255),
                       author_id bigint,
                       organization_id bigint NOT NULL,
                       course_id bigint,
                       likes_count bigint,
                       comments_count bigint,
                       created_at timestamp(6),
                       updated_at timestamp(6)
);

CREATE TABLE comments (
                          id bigserial PRIMARY KEY,
                          content text NOT NULL,
                          author_id bigint,
                          post_id bigint,
                          parent_id bigint,
                          created_at timestamp(6),
                          updated_at timestamp(6)
);

CREATE TABLE post_likes (
                            id bigserial PRIMARY KEY,
                            post_id bigint,
                            user_id bigint,
                            created_at timestamp(6),
                            UNIQUE (post_id, user_id)
);

CREATE TABLE course_placement_test_attempts (
                                                id bigserial PRIMARY KEY,
                                                user_id bigint NOT NULL,
                                                course_id bigint NOT NULL,
                                                current_block_id bigint,
                                                placed_block_id bigint,
                                                completed boolean NOT NULL DEFAULT false,
                                                correct_answers integer NOT NULL DEFAULT 0,
                                                total_answers integer NOT NULL DEFAULT 0,
                                                created_at timestamp(6),
                                                updated_at timestamp(6),
                                                UNIQUE (user_id, course_id)
);

CREATE TABLE final_quiz_attempts (
                                     id bigserial PRIMARY KEY,
                                     score integer NOT NULL,
                                     total integer NOT NULL,
                                     completed boolean NOT NULL DEFAULT true,
                                     quiz_id bigint NOT NULL,
                                     course_id bigint NOT NULL,
                                     user_id bigint NOT NULL,
                                     created_at timestamp(6),
                                     updated_at timestamp(6)
);

CREATE TABLE final_quiz_attempt_answers (
                                            id bigserial PRIMARY KEY,
                                            content text NOT NULL,
                                            correct_answer_index integer NOT NULL,
                                            selected_answer_index integer NOT NULL,
                                            correct boolean NOT NULL,
                                            source_question_id bigint NOT NULL,
                                            attempt_id bigint NOT NULL,
                                            created_at timestamp(6),
                                            updated_at timestamp(6)
);

CREATE TABLE final_quiz_attempt_answer_options (
                                                   attempt_answer_id bigint NOT NULL,
                                                   option_value varchar(255) NOT NULL
);

CREATE TABLE practice_exam_attempts (
                                        id bigserial PRIMARY KEY,
                                        score integer NOT NULL,
                                        total integer NOT NULL,
                                        practice_exam_id bigint NOT NULL,
                                        course_id bigint NOT NULL,
                                        user_id bigint NOT NULL,
                                        created_at timestamp(6),
                                        updated_at timestamp(6)
);

CREATE TABLE practice_exam_attempt_answers (
                                               id bigserial PRIMARY KEY,
                                               content text NOT NULL,
                                               correct_answer_index integer NOT NULL,
                                               selected_answer_index integer NOT NULL,
                                               correct boolean NOT NULL,
                                               source_question_id bigint NOT NULL,
                                               attempt_id bigint NOT NULL,
                                               created_at timestamp(6),
                                               updated_at timestamp(6)
);

CREATE TABLE practice_exam_attempt_answer_options (
                                                      attempt_answer_id bigint NOT NULL,
                                                      option_value varchar(255) NOT NULL
);

CREATE TABLE random_quiz_attempts (
                                      id bigserial PRIMARY KEY,
                                      course_id bigint NOT NULL,
                                      user_id bigint NOT NULL,
                                      completed boolean NOT NULL DEFAULT false,
                                      score integer,
                                      created_at timestamp(6),
                                      updated_at timestamp(6)
);

CREATE TABLE random_quiz_attempt_questions (
                                               id bigserial PRIMARY KEY,
                                               content text NOT NULL,
                                               correct_answer_index integer NOT NULL,
                                               selected_answer_index integer,
                                               correct boolean,
                                               source_question_id bigint NOT NULL,
                                               attempt_id bigint NOT NULL,
                                               created_at timestamp(6),
                                               updated_at timestamp(6)
);

CREATE TABLE random_quiz_attempt_question_options (
                                                      attempt_question_id bigint NOT NULL,
                                                      option_value varchar(255) NOT NULL
);

CREATE TABLE bank_random_quiz_attempts (
                                           id bigserial PRIMARY KEY,
                                           difficulty varchar(255) NOT NULL,
                                           completed boolean NOT NULL DEFAULT false,
                                           score integer,
                                           course_id bigint NOT NULL,
                                           user_id bigint NOT NULL,
                                           created_at timestamp(6),
                                           updated_at timestamp(6)
);

CREATE TABLE bank_random_quiz_attempt_questions (
                                                    id bigserial PRIMARY KEY,
                                                    content text NOT NULL,
                                                    correct_answer_index integer NOT NULL,
                                                    selected_answer_index integer,
                                                    correct boolean,
                                                    source_question_id bigint NOT NULL,
                                                    attempt_id bigint NOT NULL,
                                                    created_at timestamp(6),
                                                    updated_at timestamp(6)
);

CREATE TABLE bank_random_quiz_attempt_question_options (
                                                           attempt_question_id bigint NOT NULL,
                                                           option_value varchar(255) NOT NULL
);

CREATE TABLE polar_subscriptions (
                                     id bigserial PRIMARY KEY,
                                     user_id bigint NOT NULL,
                                     polar_subscription_id varchar(255) NOT NULL UNIQUE,
                                     polar_customer_id varchar(255) NOT NULL,
                                     polar_product_id varchar(255) NOT NULL,
                                     status varchar(255) NOT NULL,
                                     current_period_start timestamp(6),
                                     current_period_end timestamp(6),
                                     cancel_at_period_end boolean NOT NULL DEFAULT false,
                                     canceled_at timestamp(6),
                                     revoked_at timestamp(6),
                                     created_at timestamp(6),
                                     updated_at timestamp(6)
);

CREATE TABLE polar_webhook_events (
                                      id bigserial PRIMARY KEY,
                                      webhook_id varchar(255) NOT NULL UNIQUE,
                                      event_type varchar(255) NOT NULL,
                                      processed_at timestamp(6) NOT NULL,
                                      payload text NOT NULL,
                                      created_at timestamp(6),
                                      updated_at timestamp(6)
);

ALTER TABLE profiles
    ADD CONSTRAINT fk_profiles_user FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE user_plans
    ADD CONSTRAINT fk_user_plans_user FOREIGN KEY (user_id) REFERENCES users(id),
    ADD CONSTRAINT fk_user_plans_plan FOREIGN KEY (plan_id) REFERENCES plans(id);

ALTER TABLE user_progress
    ADD CONSTRAINT fk_user_progress_user FOREIGN KEY (user_id) REFERENCES users(id),
    ADD CONSTRAINT fk_user_progress_current_level FOREIGN KEY (current_level_id) REFERENCES levels(id);

ALTER TABLE user_activity_days
    ADD CONSTRAINT fk_user_activity_days_user FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE xp_events
    ADD CONSTRAINT fk_xp_events_user FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE organizations
    ADD CONSTRAINT fk_organizations_owner FOREIGN KEY (owner_id) REFERENCES users(id);

ALTER TABLE organization_members
    ADD CONSTRAINT fk_organization_members_organization FOREIGN KEY (organization_id) REFERENCES organizations(id),
    ADD CONSTRAINT fk_organization_members_user FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE organization_invites
    ADD CONSTRAINT fk_organization_invites_organization FOREIGN KEY (organization_id) REFERENCES organizations(id),
    ADD CONSTRAINT fk_organization_invites_user FOREIGN KEY (user_id) REFERENCES users(id),
    ADD CONSTRAINT fk_organization_invites_invited_by FOREIGN KEY (invited_by) REFERENCES users(id);

ALTER TABLE organization_join_requests
    ADD CONSTRAINT fk_organization_join_requests_organization FOREIGN KEY (organization_id) REFERENCES organizations(id),
    ADD CONSTRAINT fk_organization_join_requests_user FOREIGN KEY (user_id) REFERENCES users(id),
    ADD CONSTRAINT fk_organization_join_requests_reviewed_by FOREIGN KEY (reviewed_by_id) REFERENCES users(id);

ALTER TABLE courses
    ADD CONSTRAINT fk_courses_organization FOREIGN KEY (organization_id) REFERENCES organizations(id);

ALTER TABLE organization_media
    ADD CONSTRAINT fk_organization_media_organization FOREIGN KEY (organization_id) REFERENCES organizations(id);

ALTER TABLE course_media
    ADD CONSTRAINT fk_course_media_course FOREIGN KEY (course_id) REFERENCES courses(id),
    ADD CONSTRAINT fk_course_media_organization_media FOREIGN KEY (organization_media_id) REFERENCES organization_media(id);

ALTER TABLE post_media
    ADD CONSTRAINT fk_post_media_organization FOREIGN KEY (organization_id) REFERENCES organizations(id),
    ADD CONSTRAINT fk_post_media_organization_media FOREIGN KEY (organization_media_id) REFERENCES organization_media(id);

ALTER TABLE chapters
    ADD CONSTRAINT fk_chapters_course FOREIGN KEY (course_id) REFERENCES courses(id);

ALTER TABLE lessons
    ADD CONSTRAINT fk_lessons_chapter FOREIGN KEY (chapter_id) REFERENCES chapters(id);

ALTER TABLE questions
    ADD CONSTRAINT fk_questions_course FOREIGN KEY (course_id) REFERENCES courses(id);

ALTER TABLE question_options
    ADD CONSTRAINT fk_question_options_question FOREIGN KEY (question_id) REFERENCES questions(id);

ALTER TABLE blocks
    ADD CONSTRAINT fk_blocks_lesson FOREIGN KEY (lesson_id) REFERENCES lessons(id),
    ADD CONSTRAINT fk_blocks_question FOREIGN KEY (question_id) REFERENCES questions(id);

ALTER TABLE quizzes
    ADD CONSTRAINT fk_quizzes_course FOREIGN KEY (course_id) REFERENCES courses(id);

ALTER TABLE quiz_questions
    ADD CONSTRAINT fk_quiz_questions_quiz FOREIGN KEY (quiz_id) REFERENCES quizzes(id),
    ADD CONSTRAINT fk_quiz_questions_question FOREIGN KEY (question_id) REFERENCES questions(id);

ALTER TABLE practice_quizzes
    ADD CONSTRAINT fk_practice_quizzes_course FOREIGN KEY (course_id) REFERENCES courses(id);

ALTER TABLE practice_quiz_questions
    ADD CONSTRAINT fk_practice_quiz_questions_quiz FOREIGN KEY (practice_quiz_id) REFERENCES practice_quizzes(id),
    ADD CONSTRAINT fk_practice_quiz_questions_question FOREIGN KEY (question_id) REFERENCES questions(id);

ALTER TABLE practice_exams
    ADD CONSTRAINT fk_practice_exams_course FOREIGN KEY (course_id) REFERENCES courses(id);

ALTER TABLE practice_exam_questions
    ADD CONSTRAINT fk_practice_exam_questions_exam FOREIGN KEY (practice_exam_id) REFERENCES practice_exams(id),
    ADD CONSTRAINT fk_practice_exam_questions_question FOREIGN KEY (question_id) REFERENCES questions(id);

ALTER TABLE course_enrollments
    ADD CONSTRAINT fk_course_enrollments_user FOREIGN KEY (user_id) REFERENCES users(id),
    ADD CONSTRAINT fk_course_enrollments_course FOREIGN KEY (course_id) REFERENCES courses(id),
    ADD CONSTRAINT fk_course_enrollments_current_lesson FOREIGN KEY (current_lesson_id) REFERENCES lessons(id),
    ADD CONSTRAINT fk_course_enrollments_current_block FOREIGN KEY (current_block_id) REFERENCES blocks(id);

ALTER TABLE block_progress
    ADD CONSTRAINT fk_block_progress_user FOREIGN KEY (user_id) REFERENCES users(id),
    ADD CONSTRAINT fk_block_progress_block FOREIGN KEY (block_id) REFERENCES blocks(id);

ALTER TABLE course_faqs
    ADD CONSTRAINT fk_course_faqs_course FOREIGN KEY (course_id) REFERENCES courses(id);

ALTER TABLE certificates
    ADD CONSTRAINT fk_certificates_user FOREIGN KEY (user_id) REFERENCES users(id),
    ADD CONSTRAINT fk_certificates_course FOREIGN KEY (course_id) REFERENCES courses(id);

ALTER TABLE roadmaps
    ADD CONSTRAINT fk_roadmaps_organization FOREIGN KEY (organization_id) REFERENCES organizations(id);

ALTER TABLE roadmap_items
    ADD CONSTRAINT fk_roadmap_items_roadmap FOREIGN KEY (roadmap_id) REFERENCES roadmaps(id),
    ADD CONSTRAINT fk_roadmap_items_course FOREIGN KEY (course_id) REFERENCES courses(id);

ALTER TABLE roadmap_followers
    ADD CONSTRAINT fk_roadmap_followers_roadmap FOREIGN KEY (roadmap_id) REFERENCES roadmaps(id),
    ADD CONSTRAINT fk_roadmap_followers_user FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE posts
    ADD CONSTRAINT fk_posts_author FOREIGN KEY (author_id) REFERENCES users(id),
    ADD CONSTRAINT fk_posts_organization FOREIGN KEY (organization_id) REFERENCES organizations(id),
    ADD CONSTRAINT fk_posts_course FOREIGN KEY (course_id) REFERENCES courses(id);

ALTER TABLE comments
    ADD CONSTRAINT fk_comments_author FOREIGN KEY (author_id) REFERENCES users(id),
    ADD CONSTRAINT fk_comments_post FOREIGN KEY (post_id) REFERENCES posts(id),
    ADD CONSTRAINT fk_comments_parent FOREIGN KEY (parent_id) REFERENCES comments(id);

ALTER TABLE post_likes
    ADD CONSTRAINT fk_post_likes_post FOREIGN KEY (post_id) REFERENCES posts(id),
    ADD CONSTRAINT fk_post_likes_user FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE course_placement_test_attempts
    ADD CONSTRAINT fk_course_placement_test_attempts_user FOREIGN KEY (user_id) REFERENCES users(id),
    ADD CONSTRAINT fk_course_placement_test_attempts_course FOREIGN KEY (course_id) REFERENCES courses(id),
    ADD CONSTRAINT fk_course_placement_test_attempts_current_block FOREIGN KEY (current_block_id) REFERENCES blocks(id),
    ADD CONSTRAINT fk_course_placement_test_attempts_placed_block FOREIGN KEY (placed_block_id) REFERENCES blocks(id);

ALTER TABLE final_quiz_attempts
    ADD CONSTRAINT fk_final_quiz_attempts_quiz FOREIGN KEY (quiz_id) REFERENCES quizzes(id),
    ADD CONSTRAINT fk_final_quiz_attempts_course FOREIGN KEY (course_id) REFERENCES courses(id),
    ADD CONSTRAINT fk_final_quiz_attempts_user FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE final_quiz_attempt_answers
    ADD CONSTRAINT fk_final_quiz_attempt_answers_source_question FOREIGN KEY (source_question_id) REFERENCES questions(id),
    ADD CONSTRAINT fk_final_quiz_attempt_answers_attempt FOREIGN KEY (attempt_id) REFERENCES final_quiz_attempts(id);

ALTER TABLE final_quiz_attempt_answer_options
    ADD CONSTRAINT fk_final_quiz_attempt_answer_options_answer FOREIGN KEY (attempt_answer_id) REFERENCES final_quiz_attempt_answers(id);

ALTER TABLE practice_exam_attempts
    ADD CONSTRAINT fk_practice_exam_attempts_exam FOREIGN KEY (practice_exam_id) REFERENCES practice_exams(id),
    ADD CONSTRAINT fk_practice_exam_attempts_course FOREIGN KEY (course_id) REFERENCES courses(id),
    ADD CONSTRAINT fk_practice_exam_attempts_user FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE practice_exam_attempt_answers
    ADD CONSTRAINT fk_practice_exam_attempt_answers_source_question FOREIGN KEY (source_question_id) REFERENCES questions(id),
    ADD CONSTRAINT fk_practice_exam_attempt_answers_attempt FOREIGN KEY (attempt_id) REFERENCES practice_exam_attempts(id);

ALTER TABLE practice_exam_attempt_answer_options
    ADD CONSTRAINT fk_practice_exam_attempt_answer_options_answer FOREIGN KEY (attempt_answer_id) REFERENCES practice_exam_attempt_answers(id);

ALTER TABLE random_quiz_attempts
    ADD CONSTRAINT fk_random_quiz_attempts_course FOREIGN KEY (course_id) REFERENCES courses(id),
    ADD CONSTRAINT fk_random_quiz_attempts_user FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE random_quiz_attempt_questions
    ADD CONSTRAINT fk_random_quiz_attempt_questions_source_question FOREIGN KEY (source_question_id) REFERENCES questions(id),
    ADD CONSTRAINT fk_random_quiz_attempt_questions_attempt FOREIGN KEY (attempt_id) REFERENCES random_quiz_attempts(id);

ALTER TABLE random_quiz_attempt_question_options
    ADD CONSTRAINT fk_random_quiz_attempt_question_options_question FOREIGN KEY (attempt_question_id) REFERENCES random_quiz_attempt_questions(id);

ALTER TABLE bank_random_quiz_attempts
    ADD CONSTRAINT fk_bank_random_quiz_attempts_course FOREIGN KEY (course_id) REFERENCES courses(id),
    ADD CONSTRAINT fk_bank_random_quiz_attempts_user FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE bank_random_quiz_attempt_questions
    ADD CONSTRAINT fk_bank_random_quiz_attempt_questions_source_question FOREIGN KEY (source_question_id) REFERENCES questions(id),
    ADD CONSTRAINT fk_bank_random_quiz_attempt_questions_attempt FOREIGN KEY (attempt_id) REFERENCES bank_random_quiz_attempts(id);

ALTER TABLE bank_random_quiz_attempt_question_options
    ADD CONSTRAINT fk_bank_random_quiz_attempt_question_options_question FOREIGN KEY (attempt_question_id) REFERENCES bank_random_quiz_attempt_questions(id);

ALTER TABLE polar_subscriptions
    ADD CONSTRAINT fk_polar_subscriptions_user FOREIGN KEY (user_id) REFERENCES users(id);

CREATE INDEX idx_courses_status ON courses(status);
CREATE INDEX idx_courses_organization_status ON courses(organization_id, status);
CREATE INDEX courses_title_trgm_idx ON courses USING gin (title gin_trgm_ops);
CREATE INDEX courses_description_trgm_idx ON courses USING gin (description gin_trgm_ops);

CREATE INDEX organizations_name_trgm_idx
    ON organizations USING gin (name gin_trgm_ops);

CREATE INDEX organizations_description_trgm_idx
    ON organizations USING gin (description gin_trgm_ops);



CREATE INDEX idx_chapters_course_position ON chapters(course_id, position);
CREATE INDEX idx_lessons_chapter_position ON lessons(chapter_id, position);
CREATE INDEX idx_blocks_lesson_position ON blocks(lesson_id, position);
CREATE INDEX idx_blocks_question ON blocks(question_id);
CREATE INDEX idx_questions_course_difficulty ON questions(course_id, difficulty);

CREATE INDEX idx_course_enrollments_user_status ON course_enrollments(user_id, status);
CREATE INDEX idx_course_enrollments_course_status ON course_enrollments(course_id, status);
CREATE INDEX idx_block_progress_user_completed_block ON block_progress(user_id, completed, block_id);

CREATE INDEX idx_organization_members_user_role ON organization_members(user_id, role);
CREATE INDEX idx_organization_invites_organization_status ON organization_invites(organization_id, status);
CREATE INDEX idx_organization_join_requests_organization_status_created ON organization_join_requests(organization_id, status, created_at);

CREATE INDEX idx_organization_media_organization_created ON organization_media(organization_id, created_at);
CREATE INDEX idx_course_media_organization_media ON course_media(organization_media_id);
CREATE INDEX idx_post_media_organization_media ON post_media(organization_media_id);

CREATE INDEX idx_posts_course ON posts(course_id);
CREATE INDEX idx_posts_organization_course ON posts(organization_id, course_id);
CREATE INDEX idx_comments_post_created ON comments(post_id, created_at);
CREATE INDEX idx_post_likes_user_post ON post_likes(user_id, post_id);

CREATE INDEX idx_roadmaps_organization_created ON roadmaps(organization_id, created_at);
CREATE INDEX idx_roadmap_items_course ON roadmap_items(course_id);
CREATE INDEX idx_roadmap_followers_user_status_created ON roadmap_followers(user_id, status, created_at);

CREATE INDEX idx_user_plans_plan ON user_plans(plan_id);
CREATE INDEX idx_user_progress_current_level ON user_progress(current_level_id);
CREATE INDEX idx_xp_events_user_type_reference ON xp_events(user_id, type, reference_id);
CREATE INDEX idx_user_activity_days_user_date ON user_activity_days(user_id, activity_date);

CREATE INDEX idx_certificates_course ON certificates(course_id);
CREATE INDEX idx_course_faqs_course_position ON course_faqs(course_id, position);
CREATE INDEX idx_course_placement_test_attempts_course ON course_placement_test_attempts(course_id);

CREATE INDEX idx_quiz_questions_question ON quiz_questions(question_id);
CREATE INDEX idx_practice_quiz_questions_question ON practice_quiz_questions(question_id);
CREATE INDEX idx_practice_exam_questions_question ON practice_exam_questions(question_id);

CREATE INDEX idx_final_quiz_attempts_course_user_completed ON final_quiz_attempts(course_id, user_id, completed);
CREATE INDEX idx_final_quiz_attempt_answers_attempt ON final_quiz_attempt_answers(attempt_id);
CREATE INDEX idx_practice_exam_attempts_exam ON practice_exam_attempts(practice_exam_id);
CREATE INDEX idx_practice_exam_attempt_answers_attempt ON practice_exam_attempt_answers(attempt_id);
CREATE INDEX idx_random_quiz_attempts_course_user_completed ON random_quiz_attempts(course_id, user_id, completed);
CREATE INDEX idx_random_quiz_attempt_questions_attempt ON random_quiz_attempt_questions(attempt_id);
CREATE INDEX idx_bank_random_quiz_attempts_course_user_completed ON bank_random_quiz_attempts(course_id, user_id, completed);
CREATE INDEX idx_bank_random_quiz_attempt_questions_attempt ON bank_random_quiz_attempt_questions(attempt_id);

CREATE INDEX idx_polar_subscriptions_user_created ON polar_subscriptions(user_id, created_at);
