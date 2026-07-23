package app.lms.roadmap.service;

import app.lms.common.exception.ConflictException;
import app.lms.common.exception.NotFoundException;
import app.lms.course.model.Course;
import app.lms.course.repository.CourseRepository;
import app.lms.organization.model.Organization;
import app.lms.organization.service.OrganizationAccessService;
import app.lms.roadmap.dto.RoadmapResponse;
import app.lms.roadmap.dto.UpsertRoadmapRequest;
import app.lms.roadmap.mapper.RoadmapMapper;
import app.lms.roadmap.model.Roadmap;
import app.lms.roadmap.repository.RoadmapFollowerRepository;
import app.lms.roadmap.repository.RoadmapRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DashboardRoadmapService {

    private final OrganizationAccessService organizationAccessService;
    private final CourseRepository courseRepository;
    private final RoadmapRepository roadmapRepository;
    private final RoadmapFollowerRepository roadmapFollowerRepository;
    private final RoadmapMapper roadmapMapper;

    @Transactional
    public RoadmapResponse create(
            String organizationSlug,
            UpsertRoadmapRequest request,
            User user
    ) {

        Organization organization =
                organizationAccessService
                        .getManageableOrganization(
                                organizationSlug,
                                user
                        );

        Roadmap roadmap =
                roadmapMapper.toEntity(
                        organization,
                        orderedCourses(
                                request.courseIds(),
                                organization.getId()
                        )
                );

        roadmapRepository.save(roadmap);

        return roadmapMapper.toResponse(roadmap);
    }

    @Transactional
    public RoadmapResponse update(
            String organizationSlug,
            Long roadmapId,
            UpsertRoadmapRequest request,
            User user
    ) {

        Organization organization =
                organizationAccessService
                        .getManageableOrganization(
                                organizationSlug,
                                user
                        );

        Roadmap roadmap =
                getByIdAndOrganizationId(
                        roadmapId,
                        organization.getId()
                );

        roadmapMapper.replaceItems(
                roadmap,
                orderedCourses(
                        request.courseIds(),
                        organization.getId()
                )
        );

        return roadmapMapper.toResponse(roadmap);
    }

    @Transactional
    public RoadmapResponse getById(
            String organizationSlug,
            Long roadmapId,
            User user
    ) {

        Organization organization =
                organizationAccessService
                        .getManageableOrganization(
                                organizationSlug,
                                user
                        );

        return roadmapMapper.toResponse(
                getByIdAndOrganizationId(
                        roadmapId,
                        organization.getId()
                )
        );
    }

    @Transactional
    public Page<RoadmapResponse> list(
            String organizationSlug,
            Pageable pageable,
            User user
    ) {

        Organization organization =
                organizationAccessService
                        .getManageableOrganization(
                                organizationSlug,
                                user
                        );

        return roadmapRepository
                .findAllByOrganizationIdOrderByCreatedAtDesc(
                        organization.getId(),
                        pageable
                )
                .map(roadmapMapper::toResponse);
    }

    @Transactional
    public void delete(
            String organizationSlug,
            Long roadmapId,
            User user
    ) {

        Organization organization =
                organizationAccessService
                        .getManageableOrganization(
                                organizationSlug,
                                user
                        );

        Roadmap roadmap =
                getByIdAndOrganizationId(
                        roadmapId,
                        organization.getId()
                );

        roadmapFollowerRepository.deleteAllByRoadmapId(
                roadmap.getId()
        );

        roadmapRepository.delete(roadmap);
    }

    private Roadmap getByIdAndOrganizationId(
            Long roadmapId,
            Long organizationId
    ) {

        return roadmapRepository
                .findByIdAndOrganizationId(
                        roadmapId,
                        organizationId
                )
                .orElseThrow(() ->
                        new NotFoundException(
                                "Roadmap not found"
                        )
                );
    }

    private List<Course> orderedCourses(
            List<Long> courseIds,
            Long organizationId
    ) {

        List<Course> courses =
                courseRepository.findAllById(courseIds);

        validateCourseIds(
                courseIds,
                courses,
                organizationId
        );

        Map<Long, Course> courseMap =
                courses.stream()
                        .collect(
                                Collectors.toMap(
                                        Course::getId,
                                        Function.identity()
                                )
                        );

        return courseIds.stream()
                .map(courseMap::get)
                .toList();
    }

    private void validateCourseIds(
            List<Long> courseIds,
            List<Course> courses,
            Long organizationId
    ) {

        if (
                courseIds.stream()
                        .distinct()
                        .count()
                        != courseIds.size()
        ) {
            throw new ConflictException(
                    "Roadmap course list cannot contain duplicate courses"
            );
        }

        if (courses.size() != courseIds.size()) {
            throw new NotFoundException(
                    "Course not found"
            );
        }

        boolean hasCourseFromAnotherOrganization =
                courses.stream()
                        .anyMatch(course ->
                                !course.getOrganization()
                                        .getId()
                                        .equals(organizationId)
                        );

        if (hasCourseFromAnotherOrganization) {
            throw new ConflictException(
                    "Roadmap courses must belong to the organization"
            );
        }
    }
}
