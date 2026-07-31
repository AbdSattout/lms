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

        return commentMapper.toResponse(
                comment,
                context.reactionCountsByCommentId()
                        .getOrDefault(
                                comment.getId(),
                                Map.of()
                        ),
                context.viewerReactionsByCommentId()
                        .get(comment.getId())
        );
    }

    private CommentReactionContext reactionContext(
            List<Comment> comments,
            User user
    ) {

        List<Long> commentIds =
                comments.stream()
                        .map(Comment::getId)
                        .toList();

        if (commentIds.isEmpty()) {
            return new CommentReactionContext(
                    Map.of(),
                    Map.of()
            );
        }

        return new CommentReactionContext(
                reactionCountsByCommentId(commentIds),
                viewerReactionsByCommentId(
                        commentIds,
                        user
                )
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
            Map<Long, ReactionType> viewerReactionsByCommentId
    ) {}
}
