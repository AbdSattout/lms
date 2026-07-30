package app.lms.post.repository;

import app.lms.post.enums.PostReactionType;

public interface PostReactionCountProjection {

    Long getPostId();

    PostReactionType getReactionType();

    Long getReactionCount();
}
