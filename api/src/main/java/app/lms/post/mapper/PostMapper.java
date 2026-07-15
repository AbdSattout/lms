package app.lms.post.mapper;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.post.dto.AuthorResponse;
import app.lms.post.dto.PostResponse;
import app.lms.post.model.Post;
import org.springframework.stereotype.Component;

@Component
public class PostMapper {

    public PostResponse toResponse(Post post) {

        return new PostResponse(
                post.getId(),
                post.getTitle(),
                post.getContent(),

                new AuthorResponse(
                        post.getAuthor().getId(),
                        post.getAuthor().getName(),
                        post.getAuthor().getPicture()
                ),

                post.getOrganization().getId(),

                post.getCourse() != null
                        ? post.getCourse().getId()
                        : null,

                post.getLikesCount(),

                post.getCommentsCount(),

                BaseEntityResponse.from(post)
        );
    }
}
