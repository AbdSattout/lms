package app.lms.post.dto;

import jakarta.validation.constraints.NotBlank;

public record CreateCommentRequest(

        @NotBlank
        String content,

        Long parentCommentId

) {
}
