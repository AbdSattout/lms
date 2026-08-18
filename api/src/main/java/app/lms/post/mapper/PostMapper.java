package app.lms.post.mapper;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.post.dto.AuthorResponse;
import app.lms.post.dto.PostResponse;
import app.lms.post.enums.ReactionType;
import app.lms.post.model.Post;
import org.springframework.stereotype.Component;

import java.util.EnumMap;
import java.util.Map;

@Component
public class PostMapper {

    public PostResponse toResponse(Post post) {

        return toResponse(
                post,
                post.getCommentsCount(),
                0L,
                Map.of(),
                null
        );
    }

    public PostResponse toResponse(
            Post post,
            Long commentCount,
            Long likeCount,
            Map<ReactionType, Long> reactionCounts,
            ReactionType viewerReaction
    ) {

        return new PostResponse(
                post.getId(),
                post.getTitle(),
                post.getContent(),

                new AuthorResponse(
                        post.getAuthor().getId(),
                        post.getAuthor().getName(),
                        post.getAuthor().getPicture()
                ),

                post.getOrganization().getId(),

                post.getCourse() != null
                        ? post.getCourse().getId()
                        : null,

                commentCount != null
                        ? commentCount
                        : 0L,

                likeCount,

                completeReactionCounts(
                        reactionCounts
                ),

                viewerReaction,

                BaseEntityResponse.from(post)
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
