package app.lms.post.dto;

import app.lms.common.dto.BaseEntityResponse;

import java.time.LocalDateTime;

public record PostResponse(

        long id,

        String title,

        String content,

        AuthorResponse author,

        Long organizationId,

        long courseId,

        Long likesCount,

        Long commentsCount,

        LocalDateTime createdAt,

        LocalDateTime updatedAt,

        BaseEntityResponse baseEntity


) {
}
