package app.lms.post.repository;

import app.lms.post.enums.ReactionType;

public interface ReactionCountProjection {

    Long getTargetId();

    ReactionType getReactionType();

    Long getReactionCount();
}
