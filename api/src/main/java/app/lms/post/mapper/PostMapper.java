package app.lms.post.mapper;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.post.dto.AuthorResponse;
import app.lms.post.dto.PostResponse;
import app.lms.post.enums.PostReactionType;
import app.lms.post.model.Post;
import org.springframework.stereotype.Component;

import java.util.EnumMap;
import java.util.Map;

@Component
public class PostMapper {

    public PostResponse toResponse(Post post) {

        return toResponse(
                post,
                Map.of(),
                null
        );
    }

    public PostResponse toResponse(
            Post post,
            Map<PostReactionType, Long> reactionCounts,
            PostReactionType viewerReaction
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

                post.getCommentsCount(),

                post.getLikesCount(),

                completeReactionCounts(
                        reactionCounts
                ),

                viewerReaction,

                BaseEntityResponse.from(post)
        );
    }

    private Map<PostReactionType, Long> completeReactionCounts(
            Map<PostReactionType, Long> reactionCounts
    ) {

        Map<PostReactionType, Long> completeCounts =
                new EnumMap<>(PostReactionType.class);

        for (PostReactionType reactionType : PostReactionType.values()) {
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
