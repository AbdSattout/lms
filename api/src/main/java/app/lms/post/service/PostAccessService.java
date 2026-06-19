package app.lms.post.service;

import app.lms.common.exception.NotFoundException;
import app.lms.course.service.CourseAccessService;
import app.lms.organization.service.OrganizationAccessService;
import app.lms.post.model.Post;
import app.lms.post.repository.PostRepository;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class PostAccessService {

    private final PostRepository postRepository;
    private final OrganizationAccessService organizationAccessService;

    public Post getById(Long postId) {

        return postRepository
                .findById(postId)
                .orElseThrow(
                        () -> new NotFoundException(
                                "Post not found"
                        )
                );
    }

    public Post getEditablePost(
            Long postId,
            User user
    ) {

        Post post = getById(postId);

        organizationAccessService
                .getManageableOrganization(
                        post.getOrganization().getSlug(),
                        user
                );

        return post;
    }
}
