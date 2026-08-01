package app.lms.course.service;

import app.lms.common.exception.ConflictException;
import app.lms.common.exception.NotFoundException;
import app.lms.course.dto.CourseResponse;
import app.lms.course.dto.CreateCourseRequest;
import app.lms.course.dto.UpdateCourseRequest;
import app.lms.course.enums.CourseStatus;
import app.lms.course.mapper.CourseMapper;
import app.lms.course.model.Course;
import app.lms.course.repository.CourseRepository;
import app.lms.enrollment.model.CourseEnrollment;
import app.lms.media.dto.UploadedFile;
import app.lms.media.enums.FileType;
import app.lms.media.exception.ImageDeleteException;
import app.lms.media.service.MediaService;
import app.lms.organization.model.Organization;
import app.lms.organization.service.OrganizationAccessService;
import app.lms.plan.service.PlanQuotaService;
import app.lms.quiz.model.Quiz;
import app.lms.quiz.repository.QuizRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RequiredArgsConstructor
@Service
public class DashboardCourseService {

    private final OrganizationAccessService
            organizationAccessService;

    private final CourseRepository
            courseRepository;

    private final CourseMapper
            courseMapper;

    private final MediaService
            mediaService;

    private final CourseAccessService
            courseAccessService;

    private final QuizRepository
            quizRepository;

    private final PlanQuotaService
            planQuotaService;

    @Transactional
    public CourseResponse create(

            String slug,
            CreateCourseRequest request,
            MultipartFile cover,
            User user
    ) {

        Organization organization =
                organizationAccessService.getManageableOrganization(slug, user);

        planQuotaService.validateOrganizationCourseCreationAllowed(
                organization.getOwner(),
                () -> courseRepository.countByOrganizationId(
                        organization.getId()
                )
        );

        UploadedFile uploaded =
                hasCover(cover)
                        ? uploadCourseCover(cover)
                        : null;

        String slugValue =
                request.getSlug()
                        .trim()
                        .toLowerCase();

        if (
                slugValue.equals(
                        organization.getSlug()
                )
        ) {
            throw new ConflictException(
                    "Course slug cannot be the same as organization slug"
            );
        }

        if (
                courseRepository.existsByOrganizationIdAndSlug(
                        organization.getId(),
                        slugValue
                )
        ) {
            throw new ConflictException(
                    "Slug already exists in this organization"
            );
        }

        Course course =
                buildCourse( request,
                        organization,
                        uploaded);

        Course savedCourse =
                courseRepository.save(course);

        Quiz quiz = Quiz.builder()
                .title("Quiz for " + savedCourse.getTitle())
                .course(savedCourse)
                .build();

        quizRepository.save(quiz);

        return courseMapper.toResponse(
                savedCourse
        );
    }
    @Transactional
    public CourseResponse update(

            Long courseId,
            UpdateCourseRequest request,
            MultipartFile cover,
            User user
    ) {

        Course course =

                courseAccessService.
                        getManageableCourse(
                                courseId,
                                user
                        );

        if (request.getTitle() != null) {
            course.setTitle(
                    request.getTitle()
            );
        }

        if (request.getDescription() != null) {
            course.setDescription(
                    request.getDescription()
            );
        }
        if (hasCover(cover)) {
            updateCourseCover(
                    course,
                    cover
            );
        }

        if (request.getSlug() != null) {

            updateCourseSlug(
                    course,
                    request.getSlug()
                            .trim()
                            .toLowerCase()
            );
        }

        return courseMapper.toResponse(
                course
        );
    }
    @Transactional
    public void delete(
            Long courseId,
            User user
    ) {

        Course course =
                courseAccessService.
                        getEditableCourse(
                                courseId,
                                user
                        );

        if (course.getCoverFileId() != null) {

            mediaService.delete(
                    course.getCoverFileId()
            );
        }

        courseRepository.delete(
                course
        );
    }
    public boolean isSlugAvailable(
            String organizationSlug,
            String courseSlug,
            User user
    ) {

        Organization organization =
                organizationAccessService
                        .getManageableOrganization(
                                organizationSlug,
                                user
                        );

        courseSlug =
                courseSlug.trim()
                        .toLowerCase();

        if (
                courseSlug.equals(
                        organization.getSlug()
                )
        ) {
            return false;
        }

        return !courseRepository
                .existsByOrganizationIdAndSlug(
                        organization.getId(),
                        courseSlug
                );
    }

    @Transactional
    public void publish(
            Long courseId,
            User user
    ) {

        Course course =
                courseAccessService
                        .getManageableCourse(
                                courseId,
                                user
                        );

        validateNotPublished(course);

        validateCourseReadyForPublishing(course);

        course.setStatus(
                CourseStatus.PUBLISHED
        );
    }
    private void validateCourseReadyForPublishing(
            Course course
    ) {

        Long courseId =
                course.getId();

        if (!quizRepository.existsByCourseId(courseId)) {
            throw new ConflictException(
                    "Course must have a final quiz before publishing"
            );
        }

        long quizQuestionCount =
                quizRepository.countQuestionsByCourseId(
                        courseId
                );

        if (quizQuestionCount < 10) {
            throw new ConflictException(
                    "Course final quiz must have at least 10 questions before publishing"
            );
        }
    }


    private void validateNotPublished(
            Course course
    ) {

        if (course.getStatus()
                == CourseStatus.PUBLISHED) {

            throw new ConflictException(
                    "Course already published"
            );
        }
    }
    private void updateCourseCover(
            Course course,
            MultipartFile cover
    ) {

        String oldFileId =
                course.getCoverFileId();

        UploadedFile uploaded =
                uploadCourseCover(cover);

        course.setCoverUrl(
                uploaded.url()
        );

        course.setCoverFileId(
                uploaded.fileId()
        );

        if (oldFileId != null) {

            try {

                mediaService.delete(
                        oldFileId
                );

            } catch (ImageDeleteException ignored) {
            }
        }
    }
    private Course buildCourse(
            CreateCourseRequest request,
            Organization organization,
            UploadedFile uploaded
    ) {

        String slug =
                request.getSlug()
                        .trim()
                        .toLowerCase();

        return Course.builder()
                .title(
                        request.getTitle()
                )
                .slug(slug)
                .description(
                        request.getDescription()
                )
                .coverUrl(
                        uploaded != null
                                ? uploaded.url()
                                : null
                )
                .coverFileId(
                        uploaded != null
                                ? uploaded.fileId()
                                : null
                )
                .organization(
                        organization
                )
                .status(CourseStatus.DRAFT)
                .build();
    }

    private void updateCourseSlug(
            Course course,
            String newSlug
    ) {

        if (
                newSlug.equals(
                        course.getOrganization().getSlug()
                )
        ) {

            throw new ConflictException(
                    "Course slug cannot be the same as organization slug"
            );
        }

        if (
                !newSlug.equals(course.getSlug())
                        &&
                        courseRepository
                                .existsByOrganizationIdAndSlug(
                                        course.getOrganization().getId(),
                                        newSlug
                                )
        ) {

            throw new ConflictException(
                    "Slug already exists in this organization"
            );
        }

        course.setSlug(newSlug);
    }


    private boolean hasCover(
            MultipartFile cover
    ) {
        return cover != null && !cover.isEmpty();
    }

    private UploadedFile uploadCourseCover(
            MultipartFile cover
    ) {
        return mediaService.upload(
                cover,
                "/courses",
                FileType.IMAGE
        );
    }
    public CourseResponse getById(
            Long courseId,
            User user
    ) {

        Course course =
                courseAccessService
                        .getManageableCourse(
                                courseId,
                                user
                        );

        return courseMapper.toResponse(
                course
        );
    }

    public CourseResponse getBySlug(
            String organizationSlug,
            String courseSlug,
            User user
    ) {

        Organization organization =
                organizationAccessService
                        .getManageableOrganization(
                                organizationSlug,
                                user
                        );

        Course course =
                courseAccessService
                        .getManageableCourse(
                                organization.getId(),
                                courseSlug,
                                user
                        );

        return courseMapper.toResponse(course);
    }

    public List<CourseResponse> list(
            String organizationSlug,
            User user
    ) {

        Organization organization =
                organizationAccessService
                        .getManageableOrganization(
                                organizationSlug,
                                user
                        );

        return courseRepository
                .findAllByOrganizationId(
                        organization.getId()
                )
                .stream()
                .map(
                        courseMapper::toResponse
                )
                .toList();
    }

}
