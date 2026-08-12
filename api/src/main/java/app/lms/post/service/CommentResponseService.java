package app.lms.post.service;

import app.lms.post.dto.CommentResponse;
import app.lms.post.enums.LikeTargetType;
import app.lms.post.enums.ReactionType;
import app.lms.post.mapper.CommentMapper;
import app.lms.post.model.Comment;
import app.lms.post.model.Like;
import app.lms.post.repository.LikeRepository;
import app.lms.post.repository.ReactionCountProjection;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CommentResponseService {

    private final CommentMapper commentMapper;
    private final LikeRepository likeRepository;

    public CommentResponse build(
            Comment comment,
            User user
    ) {

        return buildList(
                List.of(comment),
                user
        ).getFirst();
    }

    public List<CommentResponse> buildList(
            List<Comment> comments,
            User user
    ) {

        CommentReactionContext context =
                reactionContext(
                        comments,
                        user
                );

        return comments.stream()
                .map(comment ->
                        build(
                                comment,
                                context
                        )
                )
                .toList();
    }

    private CommentResponse build(
            Comment comment,
            CommentReactionContext context
    ) {

        Map<ReactionType, Long> reactionCounts =
                context.reactionCountsByCommentId()
                        .getOrDefault(
                                comment.getId(),
                                Map.of()
                        );

        boolean viewerComment =
                context.viewerId() != null
                        &&
                        comment.getAuthor()
                                .getId()
                                .equals(
                                        context.viewerId()
                                );

        return commentMapper.toResponse(
                comment,
                totalReactions(reactionCounts),
                reactionCounts,
                context.viewerReactionsByCommentId()
                        .get(comment.getId()),
                viewerComment
        );
    }

    private CommentReactionContext reactionContext(
            List<Comment> comments,
            User user
    ) {

        Long viewerId =
                user != null
                        ? user.getId()
                        : null;

        List<Long> commentIds =
                comments.stream()
                        .map(Comment::getId)
                        .toList();

        if (commentIds.isEmpty()) {
            return new CommentReactionContext(
                    Map.of(),
                    Map.of(),
                    viewerId
            );
        }

        return new CommentReactionContext(
                reactionCountsByCommentId(commentIds),
                viewerReactionsByCommentId(
                        commentIds,
                        user
                ),
                viewerId
        );
    }

    private Map<Long, Map<ReactionType, Long>> reactionCountsByCommentId(
            List<Long> commentIds
    ) {

        return likeRepository
                .countCommentReactionsByCommentIds(
                        LikeTargetType.COMMENT,
                        commentIds
                )
                .stream()
                .collect(
                        Collectors.groupingBy(
                                ReactionCountProjection::getTargetId,
                                Collectors.toMap(
                                        ReactionCountProjection::getReactionType,
                                        ReactionCountProjection::getReactionCount,
                                        Long::sum,
                                        () -> new EnumMap<>(
                                                ReactionType.class
                                        )
                                )
                        )
                );
    }

    private Long totalReactions(
            Map<ReactionType, Long> reactionCounts
    ) {

        return reactionCounts
                .values()
                .stream()
                .mapToLong(Long::longValue)
                .sum();
    }

    private Map<Long, ReactionType> viewerReactionsByCommentId(
            List<Long> commentIds,
            User user
    ) {

        if (user == null) {
            return Map.of();
        }

        return likeRepository
                .findByUserIdAndCommentIds(
                        user.getId(),
                        LikeTargetType.COMMENT,
                        commentIds
                )
                .stream()
                .collect(
                        Collectors.toMap(
                                like -> like.getComment()
                                        .getId(),
                                Like::getReactionType
                        )
                );
    }

    private record CommentReactionContext(
            Map<Long, Map<ReactionType, Long>> reactionCountsByCommentId,
            Map<Long, ReactionType> viewerReactionsByCommentId,
            Long viewerId
    ) {
    }
}
