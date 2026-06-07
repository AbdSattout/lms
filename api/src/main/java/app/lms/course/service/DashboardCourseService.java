package app.lms.course.service;

import app.lms.common.exception.ConflictException;
import app.lms.course.dto.CourseResponse;
import app.lms.course.dto.CreateCourseRequest;
import app.lms.course.dto.UpdateCourseRequest;
import app.lms.course.enums.CourseStatus;
import app.lms.course.mapper.CourseMapper;
import app.lms.course.model.Course;
import app.lms.course.repository.CourseRepository;
import app.lms.media.dto.UploadedFile;
import app.lms.media.enums.FileType;
import app.lms.media.exception.ImageDeleteException;
import app.lms.media.service.MediaService;
import app.lms.organization.model.Organization;
import app.lms.organization.service.OrganizationAccessService;
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
    @Transactional
    public CourseResponse create(

            String slug,
            CreateCourseRequest request,
            MultipartFile cover,
            User user
    ) {

        Organization organization =
                organizationAccessService.getManageableOrganization(slug, user);




        UploadedFile uploaded =
                hasCover(cover)
                        ? uploadCourseCover(cover)
                        : null;

        String slugValue =
                request.getSlug()
                        .trim()
                        .toLowerCase();

        if (courseRepository.existsBySlug(slugValue)) {
            throw new ConflictException(
                    "Slug already exists"
            );
        }

        Course course =
                buildCourse( request,
                        organization,
                        uploaded);

        Course savedCourse =
                courseRepository.save(course);

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
    public boolean isSlugAvailable(String slug) {
        return !courseRepository.existsBySlug(slug);
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

        course.setStatus(
                CourseStatus.PUBLISHED
        );
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
                !newSlug.equals(
                        course.getSlug()
                )
                        &&
                        courseRepository.existsBySlug(
                                newSlug
                        )
        ) {

            throw new ConflictException(
                    "Slug already exists"
            );
        }

        course.setSlug(
                newSlug
        );
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
            String slug,
            User user
    ) {

        Course course =
                courseAccessService
                        .getManageableCourse(
                                slug,
                                user
                        );

        return courseMapper.toResponse(
                course
        );
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
