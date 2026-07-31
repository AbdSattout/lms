package app.lms.post.service;

import app.lms.common.exception.NotFoundException;
import app.lms.post.dto.CommentResponse;
import app.lms.post.dto.CreateCommentRequest;
import app.lms.post.mapper.CommentMapper;
import app.lms.post.model.Comment;
import app.lms.post.model.Post;
import app.lms.post.repository.CommentRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CommentService {

    private final CommentRepository commentRepository;
    private final CommentMapper commentMapper;
    private final PostAccessService postAccessService;
    private final CommentAccessService commentAccessService;
    private final PostService postService;

    @Transactional
    public CommentResponse create(
            Long postId,
            CreateCommentRequest request,
            User user
    ) {

        Post post =
                postService.findPostById(
                        postId
                );

        postAccessService.validateInteractionAccess(
                post,
                user
        );

        if (post.getCommentsCount() == null) {
            post.setCommentsCount(0L);
        }

        Comment parent = null;

        if (request.parentCommentId() != null && request.parentCommentId() > 0) {

            parent =
                    commentRepository
                            .findById(
                                    request.parentCommentId()
                            )
                            .orElseThrow(
                                    () ->
                                            new NotFoundException(
                                                    "Parent comment not found"
                                            )
                            );
        }

        Comment comment =
                Comment.builder()
                        .content(
                                request.content()
                        )
                        .author(user)
                        .post(post)
                        .parent(parent)
                        .build();

        commentRepository.save(
                comment
        );

        post.setCommentsCount(
                post.getCommentsCount() + 1
        );

        return commentMapper.toResponse(
                comment
        );
    }

    @Transactional
    public void delete(
            Long commentId,
            User user
    ) {

        Comment comment =
                commentAccessService
                        .getEditableComment(
                                commentId,
                                user
                        );

        Post post =
                comment.getPost();

        Long currentComments = post.getCommentsCount();
        if (currentComments == null) {
            currentComments = 0L;
        }

        long deletedCount = countCommentAndReplies(comment);

        commentRepository.delete(comment);

        post.setCommentsCount(Math.max(0, currentComments - deletedCount));
    }

    private long countCommentAndReplies(Comment comment) {
        long count = 1;
        if (comment.getReplies() != null && !comment.getReplies().isEmpty()) {
            for (Comment reply : comment.getReplies()) {
                count += countCommentAndReplies(reply);
            }
        }
        return count;
    }

    public List<CommentResponse> getPostComments(
            Long postId,
            User user
    ) {

        Post post = postService.findPostById(postId);

        postAccessService.validateMember(
                post.getOrganization(),
                user
        );

        postAccessService.validateCourseAccess(
                post,
                user
        );

        return commentRepository
                .findByPostIdOrderByCreatedAtAsc(postId)
                .stream()
                .map(commentMapper::toResponse)
                .toList();
    }
}
