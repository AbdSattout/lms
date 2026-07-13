package app.lms.post.mapper;

import app.lms.post.dto.AuthorResponse;
import app.lms.post.dto.CommentResponse;
import app.lms.post.model.Comment;
import org.springframework.stereotype.Component;

@Component
public class CommentMapper {

    public CommentResponse toResponse(
            Comment comment
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

                comment.getCreatedAt(),

                comment.getUpdatedAt()
        );
    }
}