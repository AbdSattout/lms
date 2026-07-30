package app.lms.post.service;

import app.lms.common.exception.ConflictException;
import app.lms.common.exception.NotFoundException;
import app.lms.enrollment.service.CourseEnrollmentAccessService;
import app.lms.course.model.Course;
import app.lms.course.repository.CourseRepository;
import app.lms.course.service.CourseAccessService;
import app.lms.organization.model.Organization;
import app.lms.organization.service.OrganizationAccessService;
import app.lms.organization.service.OrganizationMemberAccessService;
import app.lms.post.dto.CreatePostRequest;
import app.lms.post.dto.PostResponse;
import app.lms.post.dto.UpdatePostRequest;
import app.lms.post.mapper.PostMapper;
import app.lms.post.model.Post;
import app.lms.post.repository.PostRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class PostService {

    private final CourseAccessService courseAccessService;
    private final PostRepository postRepository;
    private final PostMapper postMapper;
    private final PostAccessService postAccessService;
    private final OrganizationAccessService organizationAccessService;
    private final CourseRepository courseRepository;
    private final OrganizationMemberAccessService organizationMemberAccessService;
    private final CourseEnrollmentAccessService courseEnrollmentAccessService;

    @Transactional
    public PostResponse create(
            String slug,
            CreatePostRequest request,
            User user
    ) {

        Organization organization =
                organizationAccessService
                        .getManageableOrganization(
                                slug,
                                user
                        );

        Course course = null;

        if (request.courseId() != null) {

            course =
                    courseAccessService
                            .getEditableCourse(
                                    request.courseId(),
                                    user
                            );

            if (!course.getOrganization().getId()
                    .equals(organization.getId())) {

                throw new ConflictException(
                        "Course does not belong to organization"
                );
            }
        }

        Post post =
                Post.builder()
                        .title(request.title())
                        .content(request.content())
                        .author(user)
                        .organization(organization)
                        .course(course)
                        .likesCount(0L)
                        .commentsCount(0L)
                        .build();

        postRepository.save(post);

        return postMapper.toResponse(
                post
        );
    }

    @Transactional
    public PostResponse update(
            Long postId,
            UpdatePostRequest request,
            User user
    ) {

        Post post = findPostById(postId);

        postAccessService.validateEditable(
                post,
                user
        );

        if (request.title() != null) {
            post.setTitle(request.title());
        }

        if (request.content() != null) {
            post.setContent(request.content());
        }

        return postMapper.toResponse(post);
    }

    @Transactional
    public void delete(
            Long postId,
            User user
    ) {

        Post post = findPostById(postId);

        postAccessService.validateEditable(
                post,
                user
        );

        postRepository.delete(post);
    }

    public Post findPostById(Long postId){
        return postRepository.findById(postId)
                .orElseThrow( () -> new NotFoundException( "Post not found" ) );
    }

    public Page<PostResponse> getOrganizationPosts(
            String slug,
            Pageable pageable
    ) {

        Organization organization =
                organizationAccessService.getBySlug(slug);

        return postRepository
                .findByOrganizationIdAndCourseIsNull(
                        organization.getId(),
                        pageable
                )
                .map(postMapper::toResponse);
    }

    public PostResponse getById(
            String slug,
            Long postId,
            User user
    ) {

        Organization organization =
                organizationAccessService.getBySlug(slug);

        Post post = findPostByIdAndOrganizationId(
                postId,
                organization.getId()
        );

        postAccessService.validateCourseAccess(
                post,
                user
        );

        return postMapper.toResponse(post);
    }

    public Page<PostResponse> getCoursePosts(
            Long courseId,
            User user,
            Pageable pageable
    ) {
        Course course = courseRepository
                .findById(courseId)
                .orElseThrow(
                        () -> new NotFoundException("Course not found")
                );

        if (!organizationMemberAccessService.isManager(
                course.getOrganization().getId(),
                user.getId()
        )) {

            courseEnrollmentAccessService.validateEnrolled(
                    courseId,
                    user
            );
        }

        Page<Post> posts = postRepository.findByCourseId(
                courseId,
                pageable
        );

        return posts.map(postMapper::toResponse);

    }

    private Post findPostByIdAndOrganizationId(
            Long postId,
            Long organizationId
    ) {
        return postRepository
                .findByIdAndOrganizationId(
                        postId,
                        organizationId
                )
                .orElseThrow(
                        () -> new NotFoundException("Post not found")
                );
    }
}
