package app.lms.course.service;

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

        public CourseDetailsResponse getBySlug(
                String slug
        ) {

            Course course =
                    courseAccessService.getPublishedBySlug(
                            slug
                    );

            return courseMapper.toDetailsResponse(
                    course
            );
        }


    public CourseResponse getById(
            Long courseId,
            User user
    ) {

        Course course =
                courseAccessService
                        .getAccessibleCourse(
                                courseId,
                                user
                        );

        return courseMapper.toResponse(
                course
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
