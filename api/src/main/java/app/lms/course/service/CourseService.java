package app.lms.course.service;

import app.lms.courceEnrollment.model.CourseEnrollment;
import app.lms.courceEnrollment.service.CourseEnrollmentAccessService;
import app.lms.course.dto.CourseDetailsResponse;
import app.lms.course.dto.CourseResponse;
import app.lms.course.enums.CourseStatus;
import app.lms.course.mapper.CourseMapper;
import app.lms.course.model.Course;
import app.lms.course.repository.CourseRepository;
import app.lms.organization.model.Organization;
import app.lms.organization.service.OrganizationAccessService;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CourseService {

    private final CourseRepository courseRepository;

    private final CourseMapper courseMapper;

    private final OrganizationAccessService organizationAccessService;

    private final CourseAccessService courseAccessService;

    private final CourseEnrollmentAccessService courseEnrollmentAccessService;

        public CourseResponse getBySlug(
                String slug
        ) {

            Course course =
                    courseAccessService.getPublishedBySlug(
                            slug
                    );

            return courseMapper.toResponse(
                    course
            );
        }


    public CourseDetailsResponse getById(
            Long courseId,
            User user
    ) {

        Course course =
                courseAccessService
                        .getEnrolledCourse(
                                courseId,
                                user
                        );
        CourseEnrollment enrollment =
                courseEnrollmentAccessService
                        .getEnrollment(
                                courseId,
                                user
                        );

        return courseMapper.toDetailsResponse(
                course,
                enrollment
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
                .findAllByOrganizationIdAndStatus(
                        organization.getId(),
                        CourseStatus.PUBLISHED,
                        pageable
                )
                .map(courseMapper::toResponse);
    }






}
