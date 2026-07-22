package app.lms.post.service;

import app.lms.common.exception.NotFoundException;
import app.lms.post.model.Comment;
import app.lms.post.repository.CommentRepository;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CommentAccessService {

    private final CommentRepository commentRepository;
    private final PostAccessService postAccessService;

    public Comment getById(Long commentId) {

        return commentRepository
                .findById(commentId)
                .orElseThrow(
                        () -> new NotFoundException(
                                "Comment not found"
                        )
                );
    }

    public Comment getEditableComment(
            Long commentId,
            User user
    ) {

        Comment comment =
                getById(commentId);

        postAccessService.validateEditable(
                comment.getPost(),
                user
        );

        return comment;
    }
}