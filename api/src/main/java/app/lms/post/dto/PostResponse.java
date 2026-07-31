package app.lms.post.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.post.enums.ReactionType;
import com.fasterxml.jackson.annotation.JsonInclude;

import java.util.Map;

public record PostResponse(

        long id,

        String title,

        String content,

        AuthorResponse author,

        Long organizationId,

        Long courseId,

        Long commentCount,

        Long likeCount,

        Map<ReactionType, Long> reactionCounts,

        @JsonInclude(JsonInclude.Include.NON_NULL)
        ReactionType viewerReaction,

        BaseEntityResponse baseEntity
) {
}
