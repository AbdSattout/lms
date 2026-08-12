package app.lms.post.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.post.enums.ReactionType;
import com.fasterxml.jackson.annotation.JsonInclude;

import java.util.Map;

public record CommentResponse(

        long id,

        String content,

        AuthorResponse author,

        Long parentCommentId,

        Long likeCount,

        Map<ReactionType, Long> reactionCounts,

        @JsonInclude(JsonInclude.Include.NON_NULL)
        ReactionType viewerReaction,

        Boolean viewerComment,

        BaseEntityResponse baseEntity

) {
}