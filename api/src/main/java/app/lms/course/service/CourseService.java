package app.lms.course.service;

import app.lms.enrollment.model.CourseEnrollment;
import app.lms.enrollment.enums.EnrollmentStatus;
import app.lms.enrollment.repository.CourseEnrollmentRepository;
import app.lms.enrollment.service.CourseEnrollmentAccessService;
import app.lms.course.dto.CourseDetailsResponse;
import app.lms.course.dto.CourseResponse;
import app.lms.course.enums.CourseStatus;
import app.lms.course.mapper.CourseMapper;
import app.lms.course.model.Course;
import app.lms.course.repository.CourseRepository;
import app.lms.organization.model.Organization;
import app.lms.organization.service.OrganizationAccessService;
import app.lms.placementTest.service.CoursePlacementTestAccessService;
import app.lms.progress.repository.BlockProgressRepository;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CourseService {

    private final CourseRepository courseRepository;

    private final CourseMapper courseMapper;

    private final OrganizationAccessService organizationAccessService;

    private final CourseAccessService courseAccessService;

    private final CourseEnrollmentAccessService courseEnrollmentAccessService;
    private final BlockProgressRepository blockProgressRepository;
    private final CourseEnrollmentRepository courseEnrollmentRepository;
    private final CoursePlacementTestAccessService placementTestAccessService;

    @Value("${app.search.course-similarity-threshold:0.2}")
    private double courseSearchSimilarityThreshold;

    public CourseResponse getBySlug(
            String organizationSlug,
            String courseSlug
    ) {

        Organization organization =
                organizationAccessService
                        .getBySlug(
                                organizationSlug
                        );

        Course course =
                courseAccessService
                        .getPublishedBySlug(
                                organization.getId(),
                                courseSlug
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

        placementTestAccessService
                .validateCompletedOrSkipped(
                        courseId,
                        user
                );

        return courseMapper.toDetailsResponse(
                course,
                enrollment,
                blockProgressRepository.findCompletedBlockIdsByUserIdAndCourseId(
                        user.getId(),
                        courseId
                )
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

    public Page<CourseResponse> getAll(
            String q,
            Pageable pageable,
            User user
    ) {

        Page<Course> courses =
                StringUtils.hasText(q)
                        ? courseRepository
                                .searchAllByStatus(
                                        CourseStatus.PUBLISHED.name(),
                                        q.trim(),
                                        courseSearchSimilarityThreshold,
                                        pageable
                                )
                        : courseRepository
                                .findAllByStatus(
                                        CourseStatus.PUBLISHED,
                                        pageable
                                );

        return toCourseResponses(
                courses,
                user
        );
    }

    private Page<CourseResponse> toCourseResponses(
            Page<Course> courses,
            User user
    ) {

        List<Long> courseIds =
                courses.getContent()
                        .stream()
                        .map(Course::getId)
                        .toList();

        Map<Long, CourseEnrollment> enrollmentsByCourseId =
                courseIds.isEmpty()
                        ? Map.of()
                        : courseEnrollmentRepository
                                .findAllByUserIdAndStatusAndCourseIdIn(
                                        user.getId(),
                                        EnrollmentStatus.ACTIVE,
                                        courseIds
                                )
                                .stream()
                                .collect(
                                        Collectors.toMap(
                                                enrollment ->
                                                        enrollment.getCourse()
                                                                .getId(),
                                                Function.identity()
                                        )
                                );

        return courses.map(course ->
                courseMapper.toResponse(
                        course,
                        enrollmentsByCourseId.get(course.getId())
                )
        );
    }





}
