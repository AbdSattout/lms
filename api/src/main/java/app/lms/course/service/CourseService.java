package app.lms.course.service;

import app.lms.course.dto.CourseResponse;
import app.lms.course.dto.CreateCourseRequest;
import app.lms.course.dto.UpdateCourseRequest;
import app.lms.course.mapper.CourseMapper;
import app.lms.course.model.Course;
import app.lms.course.repository.CourseRepository;
import app.lms.media.dto.UploadedFile;
import app.lms.media.enums.FileType;
import app.lms.media.service.MediaService;
import app.lms.organization.model.Organization;
import app.lms.organization.service.OrganizationAccessService;
import app.lms.organization.service.OrganizationMemberAccessService;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
public class CourseService {

    private final CourseRepository courseRepository;

    private final MediaService mediaService;

    private final CourseMapper courseMapper;

    private final OrganizationAccessService organizationAccessService;

    private final OrganizationMemberAccessService organizationMemberAccessService;

    private final CourseAccessService courseAccessService;
    @Transactional
    public CourseResponse create(

            String slug,
            CreateCourseRequest request,
            MultipartFile cover,
            User user
    ) {

        Organization organization =
                organizationAccessService.getBySlug(slug);



        organizationMemberAccessService
                .getManagerMember(
                        organization.getId(),
                        user.getId()
                );

        UploadedFile uploaded =
                hasCover(cover)
                        ? uploadCourseCover(cover)
                        : null;

        Course course =
                Course.builder()
                        .title(request.getTitle())
                        .description(request.getDescription())
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
                        .organization(organization)
                        .build();

        courseRepository.save(course);

        return courseMapper.toResponse(course);
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
                getManagedCourse(
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

            if (course.getCoverFileId() != null) {

                mediaService.delete(
                        course.getCoverFileId()
                );
            }

            UploadedFile uploaded =
                    uploadCourseCover(cover);

            course.setCoverUrl(
                    uploaded.url()
            );

            course.setCoverFileId(
                    uploaded.fileId()
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
                getManagedCourse(
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

    public CourseResponse getById(
            Long courseId
    ) {

        Course course = courseAccessService.getById(courseId);


        return courseMapper.toResponse(
                course
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

    public Page<CourseResponse> list(

            String organizationSlug,
            Pageable pageable
    ) {

        Organization organization =
                organizationAccessService
                        .getBySlug(
                                organizationSlug
                        );

        return courseRepository
                .findAllByOrganizationId(
                        organization.getId(),
                        pageable
                )
                .map(courseMapper::toResponse);
    }

}
