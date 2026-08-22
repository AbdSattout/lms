package app.lms.media.service;

import app.lms.common.exception.NotFoundException;
import app.lms.course.model.Course;
import app.lms.course.service.CourseAccessService;
import app.lms.media.dto.CourseMediaResponse;
import app.lms.media.mapper.CourseMediaMapper;
import app.lms.media.model.CourseMedia;
import app.lms.media.model.OrganizationMedia;
import app.lms.media.repository.CourseMediaRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
public class DashboardCourseMediaService {

    private final CourseMediaRepository courseMediaRepository;
    private final CourseAccessService courseAccessService;
    private final CourseMediaAccessService courseMediaAccessService;
    private final CourseMediaMapper courseMediaMapper;
    private final DashboardMediaStorageService mediaStorageService;

    @Transactional
    public CourseMediaResponse create(
            Long organizationId,
            Long courseId,
            MultipartFile file,
            User user
    ) {

        Course course =
                courseAccessService
                        .getManageableCourse(
                                courseId,
                                user
                        );

        validateCourseOrganization(
                course,
                organizationId
        );

        CourseMedia media =
                buildMedia(
                        course,
                        file
                );

        courseMediaRepository.save(media);

        return courseMediaMapper.toResponse(media);
    }

    @Transactional
    public CourseMediaResponse update(
            Long organizationId,
            Long courseId,
            Long mediaId,
            MultipartFile file,
            String name,
            User user
    ) {

        CourseMedia media =
                courseMediaAccessService
                        .getManageableMedia(
                                organizationId,
                                courseId,
                                mediaId,
                                user
                        );

        mediaStorageService.validateUpdateRequest(
                file,
                name
        );

        if (name != null) {
            updateName(
                    media,
                    name
            );
        }

        if (file != null) {
            updateFile(
                    media,
                    file
            );
        }

        return courseMediaMapper.toResponse(media);
    }

    @Transactional
    public void delete(
            Long organizationId,
            Long courseId,
            Long mediaId,
            User user
    ) {

        CourseMedia media =
                courseMediaAccessService
                        .getEditableMedia(
                                organizationId,
                                courseId,
                                mediaId,
                                user
                        );

        OrganizationMedia organizationMedia =
                media.getOrganizationMedia();

        mediaStorageService.deleteCourseMediaFileIfUnused(
                organizationMedia
        );

        courseMediaRepository.delete(media);
    }

    public CourseMediaResponse getById(
            Long organizationId,
            Long courseId,
            Long mediaId,
            User user
    ) {

        CourseMedia media =
                courseMediaAccessService
                        .getManageableMedia(
                                organizationId,
                                courseId,
                                mediaId,
                                user
                        );

        return courseMediaMapper.toResponse(
                media
        );
    }

    public Page<CourseMediaResponse> list(
            Long organizationId,
            Long courseId,
            Pageable pageable,
            User user
    ) {

        Course course =
                courseAccessService
                        .getManageableCourse(
                                courseId,
                                user
                        );

        validateCourseOrganization(
                course,
                organizationId
        );

        return courseMediaRepository
                .findAllByCourseIdOrderByCreatedAtDesc(
                        course.getId(),
                        pageable
                )
                .map(courseMediaMapper::toResponse);
    }

    private void updateName(
            CourseMedia media,
            String name
    ) {

        mediaStorageService.rename(
                media.getOrganizationMedia(),
                media.getCourse()
                        .getOrganization()
                        .getId(),
                name,
                "Media name already exists in this course"
        );
    }

    private void updateFile(
            CourseMedia media,
            MultipartFile file
    ) {

        mediaStorageService.replaceFile(
                media.getCourse().getOrganization(),
                media.getOrganizationMedia(),
                file,
                "/courses/" + media.getCourse().getId()
        );
    }

    private CourseMedia buildMedia(
            Course course,
            MultipartFile file
    ) {

        OrganizationMedia organizationMedia =
                mediaStorageService.upload(
                        course.getOrganization(),
                        file,
                        "/courses/" + course.getId()
                );

        return CourseMedia.builder()
                .course(course)
                .organizationMedia(organizationMedia)
                .build();
    }

    private void validateCourseOrganization(
            Course course,
            Long organizationId
    ) {

        if (
                !course.getOrganization()
                        .getId()
                        .equals(organizationId)
        ) {
            throw new NotFoundException(
                    "Course not found"
            );
        }
    }
}
