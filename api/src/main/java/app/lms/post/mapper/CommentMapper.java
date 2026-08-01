package app.lms.post.mapper;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.post.dto.AuthorResponse;
import app.lms.post.dto.CommentResponse;
import app.lms.post.enums.ReactionType;
import app.lms.post.model.Comment;
import org.springframework.stereotype.Component;

import java.util.EnumMap;
import java.util.Map;

@Component
public class CommentMapper {

    public CommentResponse toResponse(
            Comment comment
    ) {

        return toResponse(
                comment,
                0L,
                Map.of(),
                null
        );
    }

    public CommentResponse toResponse(
            Comment comment,
            Long likeCount,
            Map<ReactionType, Long> reactionCounts,
            ReactionType viewerReaction
    ) {

        return new CommentResponse(
                comment.getId(),
                comment.getContent(),

                new AuthorResponse(
                        comment.getAuthor().getId(),
                        comment.getAuthor().getName(),
                        comment.getAuthor().getPicture()
                ),

                comment.getParent() != null
                        ? comment.getParent().getId()
                        : null,

                likeCount,

                completeReactionCounts(
                        reactionCounts
                ),

                viewerReaction,

                BaseEntityResponse.from(comment)
        );
    }

    private Map<ReactionType, Long> completeReactionCounts(
            Map<ReactionType, Long> reactionCounts
    ) {

        Map<ReactionType, Long> completeCounts =
                new EnumMap<>(ReactionType.class);

        for (ReactionType reactionType : ReactionType.values()) {
            completeCounts.put(
                    reactionType,
                    reactionCounts.getOrDefault(
                            reactionType,
                            0L
                    )
            );
        }

        return completeCounts;
    }
}
