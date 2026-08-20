package app.lms.post.service;

import app.lms.post.dto.CommentResponse;
import app.lms.post.enums.LikeTargetType;
import app.lms.post.enums.ReactionType;
import app.lms.post.mapper.CommentMapper;
import app.lms.post.model.Comment;
import app.lms.post.model.Like;
import app.lms.post.repository.CommentRepository;
import app.lms.post.repository.LikeRepository;
import app.lms.post.repository.ReactionCountProjection;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.stereotype.Service;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CommentResponseService {
    private final CommentMapper commentMapper;
    private final LikeRepository likeRepository;
    private final CommentRepository commentRepository;
    public CommentResponse build(
            Comment comment,
            User user
    ) {

        CommentReactionContext context =
                reactionContext(
                        List.of(comment),
                        user
                );

        List<Comment> postComments =
                commentRepository.findByPostId(
                        comment.getPost().getId()
                );

        Map<Long, Long> repliesCounts =
                calculateRepliesCounts(
                        postComments
                );

        return build(
                comment,
                context,
                repliesCounts.getOrDefault(
                        comment.getId(),
                        0L
                )
        );
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

        List<Long> postIds =
                comments.stream()
                        .map(comment ->
                                comment.getPost().getId()
                        )
                        .distinct()
                        .toList();

        List<Comment> allPostComments =
                postIds.isEmpty()
                        ? List.of()
                        : commentRepository.findByPostIdIn(
                        postIds
                );

        Map<Long, Long> repliesCounts =
                calculateRepliesCounts(
                        allPostComments
                );

        return comments.stream()
                .map(comment ->
                        build(
                                comment,
                                context,
                                repliesCounts.getOrDefault(
                                        comment.getId(),
                                        0L
                                )
                        )
                )
                .toList();
    }

    public Page<CommentResponse> buildPage(
            Page<Comment> comments,
            User user
    ) {

        List<Comment> content =
                comments.getContent();

        CommentReactionContext context =
                reactionContext(
                        content,
                        user
                );

        List<Long> postIds =
                content.stream()
                        .map(comment ->
                                comment.getPost().getId()
                        )
                        .distinct()
                        .toList();

        List<Comment> allPostComments =
                postIds.isEmpty()
                        ? List.of()
                        : commentRepository.findByPostIdIn(
                        postIds
                );

        Map<Long, Long> repliesCounts =
                calculateRepliesCounts(
                        allPostComments
                );

        return comments.map(comment ->
                build(
                        comment,
                        context,
                        repliesCounts.getOrDefault(
                                comment.getId(),
                                0L
                        )
                )
        );
    }

    private CommentResponse build(
            Comment comment,
            CommentReactionContext context,
            Long repliesCount
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

                repliesCount,

                reactionCounts,

                context.viewerReactionsByCommentId()
                        .get(comment.getId()),

                viewerComment
        );
    }

    private Map<Long, Long> calculateRepliesCounts(
            List<Comment> comments
    ) {

        Map<Long, List<Long>> childrenByParent = new HashMap<>();

        for (Comment comment : comments) {

            if (comment.getParent() != null) {

                Long parentId = comment.getParent().getId();

                childrenByParent
                        .computeIfAbsent(
                                parentId,
                                ignored -> new ArrayList<>()
                        )
                        .add(comment.getId());
            }
        }

        Map<Long, Long> memo = new HashMap<>();

        for (Comment comment : comments) {
            countDescendants(
                    comment.getId(),
                    childrenByParent,
                    memo
            );
        }

        return memo;
    }

    private long countDescendants(
            Long commentId,
            Map<Long, List<Long>> childrenByParent,
            Map<Long, Long> memo
    ) {

        if (memo.containsKey(commentId)) {
            return memo.get(commentId);
        }

        List<Long> children =
                childrenByParent.getOrDefault(
                        commentId,
                        List.of()
                );

        long count = 0;

        for (Long childId : children) {

            // count the child itself
            count++;

            // count all children under that child
            count += countDescendants(
                    childId,
                    childrenByParent,
                    memo
            );
        }

        memo.put(
                commentId,
                count
        );

        return count;
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
