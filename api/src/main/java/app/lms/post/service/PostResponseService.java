package app.lms.post.service;

import app.lms.post.dto.PostResponse;
import app.lms.post.enums.PostReactionType;
import app.lms.post.mapper.PostMapper;
import app.lms.post.model.Post;
import app.lms.post.model.PostLike;
import app.lms.post.repository.PostLikeRepository;
import app.lms.post.repository.PostReactionCountProjection;
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
    private final PostLikeRepository postLikeRepository;

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

        return postMapper.toResponse(
                post,
                context.reactionCountsByPostId()
                        .getOrDefault(
                                post.getId(),
                                Map.of()
                        ),
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

    private Map<Long, Map<PostReactionType, Long>> reactionCountsByPostId(
            List<Long> postIds
    ) {

        return postLikeRepository
                .countReactionsByPostIds(postIds)
                .stream()
                .collect(
                        Collectors.groupingBy(
                                PostReactionCountProjection::getPostId,
                                Collectors.toMap(
                                        PostReactionCountProjection::getReactionType,
                                        PostReactionCountProjection::getReactionCount,
                                        Long::sum,
                                        () -> new EnumMap<>(
                                                PostReactionType.class
                                        )
                                )
                        )
                );
    }

    private Map<Long, PostReactionType> viewerReactionsByPostId(
            List<Long> postIds,
            User user
    ) {

        if (user == null) {
            return Map.of();
        }

        return postLikeRepository
                .findAllByUserIdAndPostIdIn(
                        user.getId(),
                        postIds
                )
                .stream()
                .collect(
                        Collectors.toMap(
                                like -> like.getPost()
                                        .getId(),
                                PostLike::getReactionType
                        )
                );
    }

    private record PostReactionContext(
            Map<Long, Map<PostReactionType, Long>> reactionCountsByPostId,
            Map<Long, PostReactionType> viewerReactionsByPostId
    ) {}
}
