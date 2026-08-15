package app.lms.admin.service;

import app.lms.admin.model.Admin;
import app.lms.common.exception.NotFoundException;
import app.lms.course.dto.CourseResponse;
import app.lms.course.mapper.CourseMapper;
import app.lms.course.repository.CourseRepository;
import app.lms.organization.dto.OrganizationResponse;
import app.lms.organization.mapper.OrganizationMapper;
import app.lms.organization.model.Organization;
import app.lms.post.dto.CommentResponse;
import app.lms.post.dto.PostResponse;
import app.lms.post.model.Post;
import app.lms.post.repository.CommentRepository;
import app.lms.post.repository.PostRepository;
import app.lms.post.service.CommentResponseService;
import app.lms.post.service.PostResponseService;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AdminContentService {

    private static final int USER_CONTENT_PAGE_SIZE = 5;

    private final AdminModerationAccessService accessService;
    private final OrganizationMapper organizationMapper;
    private final CourseRepository courseRepository;
    private final CourseMapper courseMapper;
    private final PostRepository postRepository;
    private final PostResponseService postResponseService;
    private final CommentRepository commentRepository;
    private final CommentResponseService commentResponseService;

    @Transactional(readOnly = true)
    public OrganizationResponse getOrganization(
            Long organizationId,
            Long adminId
    ) {

        validateAdmin(adminId);

        Organization organization =
                accessService.getOrganization(
                        organizationId
                );

        return organizationMapper.ToResponse(
                organization
        );
    }

    @Transactional(readOnly = true)
    public Page<CourseResponse> getOrganizationCourses(
            Long organizationId,
            Long adminId,
            Pageable pageable
    ) {

        validateAdmin(adminId);

        accessService.getOrganization(
                organizationId
        );

        return courseRepository
                .findAllByOrganizationId(
                        organizationId,
                        pageable
                )
                .map(courseMapper::toResponse);
    }

    @Transactional(readOnly = true)
    public PostResponse getOrganizationPost(
            Long organizationId,
            Long postId,
            Long adminId
    ) {

        validateAdmin(adminId);

        accessService.getOrganization(
                organizationId
        );

        Post post =
                postRepository
                        .findByIdAndOrganizationId(
                                postId,
                                organizationId
                        )
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "Post not found"
                                )
                        );

        return postResponseService.build(
                post,
                null
        );
    }

    @Transactional(readOnly = true)
    public Page<PostResponse> getUserPosts(
            Long userId,
            Long adminId,
            Pageable pageable
    ) {

        validateAdmin(adminId);
        getUser(userId);

        return postResponseService.buildPage(
                postRepository.findAllByAuthorId(
                        userId,
                        userContentPageable(pageable)
                ),
                null
        );
    }

    @Transactional(readOnly = true)
    public Page<CommentResponse> getUserComments(
            Long userId,
            Long adminId,
            Pageable pageable
    ) {

        validateAdmin(adminId);
        getUser(userId);

        return commentResponseService.buildPage(
                commentRepository.findAllByAuthorId(
                        userId,
                        userContentPageable(pageable)
                ),
                null
        );
    }

    private void validateAdmin(
            Long adminId
    ) {

        Admin admin =
                accessService.getAdmin(
                        adminId
                );

        accessService.validateAdmin(admin);
    }

    private User getUser(
            Long userId
    ) {

        return accessService.getUser(
                userId
        );
    }

    private Pageable userContentPageable(
            Pageable pageable
    ) {

        int pageNumber =
                pageable != null
                        ? pageable.getPageNumber()
                        : 0;

        return PageRequest.of(
                pageNumber,
                USER_CONTENT_PAGE_SIZE,
                Sort.by(
                        Sort.Direction.DESC,
                        "createdAt"
                )
        );
    }
}
