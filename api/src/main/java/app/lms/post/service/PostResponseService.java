package app.lms.post.service;

import app.lms.post.dto.PostResponse;
import app.lms.post.enums.LikeTargetType;
import app.lms.post.enums.ReactionType;
import app.lms.post.mapper.PostMapper;
import app.lms.post.model.Like;
import app.lms.post.model.Post;
import app.lms.post.repository.LikeRepository;
import app.lms.post.repository.ReactionCountProjection;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.stereotype.Service;

import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PostResponseService {

    private final PostMapper postMapper;
    private final LikeRepository likeRepository;

    public PostResponse build(
            Post post,
            User user
    ) {

        return buildList(
                List.of(post),
                user
        ).getFirst();
    }

    public Page<PostResponse> buildPage(
            Page<Post> posts,
            User user
    ) {

        PostReactionContext context =
                reactionContext(
                        posts.getContent(),
                        user
                );

        return posts.map(post ->
                build(
                        post,
                        context
                )
        );
    }

    public List<PostResponse> buildList(
            List<Post> posts,
            User user
    ) {

        PostReactionContext context =
                reactionContext(
                        posts,
                        user
                );

        return posts.stream()
                .map(post ->
                        build(
                                post,
                                context
                        )
                )
                .toList();
    }

    private PostResponse build(
            Post post,
            PostReactionContext context
    ) {

        Map<ReactionType, Long> reactionCounts =
                context.reactionCountsByPostId()
                        .getOrDefault(
                                post.getId(),
                                Map.of()
                        );

        return postMapper.toResponse(
                post,
                totalReactions(reactionCounts),
                reactionCounts,
                context.viewerReactionsByPostId()
                        .get(post.getId())
        );
    }

    private PostReactionContext reactionContext(
            List<Post> posts,
            User user
    ) {

        List<Long> postIds =
                posts.stream()
                        .map(Post::getId)
                        .toList();

        if (postIds.isEmpty()) {
            return new PostReactionContext(
                    Map.of(),
                    Map.of()
            );
        }

        return new PostReactionContext(
                reactionCountsByPostId(postIds),
                viewerReactionsByPostId(
                        postIds,
                        user
                )
        );
    }

    private Map<Long, Map<ReactionType, Long>> reactionCountsByPostId(
            List<Long> postIds
    ) {

        return likeRepository
                .countPostReactionsByPostIds(
                        LikeTargetType.POST,
                        postIds
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

    private Map<Long, ReactionType> viewerReactionsByPostId(
            List<Long> postIds,
            User user
    ) {

        if (user == null) {
            return Map.of();
        }

        return likeRepository
                .findByUserIdAndPostIds(
                        user.getId(),
                        LikeTargetType.POST,
                        postIds
                )
                .stream()
                .collect(
                        Collectors.toMap(
                                like -> like.getPost()
                                        .getId(),
                                Like::getReactionType
                        )
                );
    }

    private record PostReactionContext(
            Map<Long, Map<ReactionType, Long>> reactionCountsByPostId,
            Map<Long, ReactionType> viewerReactionsByPostId
    ) {}
}
