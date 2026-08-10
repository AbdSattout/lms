package app.lms.post.service;

import app.lms.common.exception.ConflictException;
import app.lms.common.exception.NotFoundException;
import app.lms.course.model.Course;
import app.lms.course.service.CourseAccessService;
import app.lms.notification.enums.NotificationType;
import app.lms.notification.service.NotificationService;
import app.lms.organization.model.Organization;
import app.lms.organization.service.OrganizationAccessService;
import app.lms.post.dto.CreatePostRequest;
import app.lms.post.dto.PostResponse;
import app.lms.post.dto.UpdatePostRequest;
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
    private final PostResponseService postResponseService;
    private final PostAccessService postAccessService;
    private final OrganizationAccessService organizationAccessService;
    private final NotificationService notificationService;

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
                        .commentsCount(0L)
                        .build();

        postRepository.save(post);

        if ( request.courseId() != null){
            notificationService.notifyCourseMember(
                    course,
                    NotificationType.NEW_POST,
                    "New Post",
                    user.getName() +
                            " published a new post.",
                    "POST",
                    post.getId()
            );
        }
        else notificationService.notifyOrganizationStudents(
                organization,
                NotificationType.NEW_POST,
                "New Post",
                user.getName() +
                        " published a new post.",
                "POST",
                post.getId()
        );

        return postResponseService.build(
                post,
                user
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

        return postResponseService.build(
                post,
                user
        );
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
    public PostResponse getCoursePostById(
            Long courseId,
            Long postId,
            User user
    ) {

        Course course =
                courseAccessService
                        .getEnrolledCourse(
                                courseId,
                                user
                        );

        Post post =
                postRepository
                        .findByIdAndCourseId(
                                postId,
                                course.getId()
                        )
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "Post not found"
                                )
                        );

        return postResponseService.build(
                post,
                user
        );
    }

    public Page<PostResponse> getOrganizationPosts(
            String slug,
            User user,
            Pageable pageable
    ) {

        Organization organization =
                organizationAccessService.getBySlug(slug);

        postAccessService.validateOrganizationAccess(
                organization,
                user
        );

        Page<Post> posts = postRepository
                .findByOrganizationIdAndCourseIsNull(
                        organization.getId(),
                        pageable
                );

        return postResponseService.buildPage(
                posts,
                user
        );
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

        return postResponseService.build(
                post,
                user
        );
    }

    public Page<PostResponse> getCoursePosts(
            Long courseId,
            User user,
            Pageable pageable
    ) {
        Course course =
                courseAccessService
                        .getEnrolledCourse(
                                courseId,
                                user
                        );

        Page<Post> posts = postRepository.findByCourseId(
                course.getId(),
                pageable
        );

        return postResponseService.buildPage(
                posts,
                user
        );

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
