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
import app.lms.roadmap.model.RoadmapItem;
import app.lms.roadmap.repository.RoadmapRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RoadmapService {

    private final OrganizationAccessService organizationAccessService;
    private final CourseRepository courseRepository;
    private final RoadmapRepository roadmapRepository;
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

        if (
                roadmapRepository.existsByOrganizationId(
                        organization.getId()
                )
        ) {
            throw new ConflictException(
                    "Roadmap already exists"
            );
        }

        Roadmap roadmap =
                Roadmap.builder()
                        .organization(
                                organization
                        )
                        .build();

        replaceItems(
                roadmap,
                request.courseIds(),
                organization.getId()
        );

        roadmapRepository.save(
                roadmap
        );

        return roadmapMapper.toResponse(
                roadmap
        );
    }

    @Transactional
    public RoadmapResponse update(
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
                getByOrganizationId(
                        organization.getId()
                );

        replaceItems(
                roadmap,
                request.courseIds(),
                organization.getId()
        );

        return roadmapMapper.toResponse(
                roadmap
        );
    }

    @Transactional
    public RoadmapResponse getManageable(
            String organizationSlug,
            User user
    ) {

        Organization organization =
                organizationAccessService
                        .getManageableOrganization(
                                organizationSlug,
                                user
                        );

        return roadmapMapper.toResponse(
                getByOrganizationId(
                        organization.getId()
                )
        );
    }

    @Transactional
    public RoadmapResponse getPublished(
            String organizationSlug
    ) {

        Organization organization =
                organizationAccessService
                        .getBySlug(
                                organizationSlug
                        );

        return roadmapMapper.toResponse(
                getByOrganizationId(
                        organization.getId()
                ),
                true
        );
    }

    private Roadmap getByOrganizationId(
            Long organizationId
    ) {

        return roadmapRepository
                .findByOrganizationId(
                        organizationId
                )
                .orElseThrow(() ->
                        new NotFoundException(
                                "Roadmap not found"
                        )
                );
    }

    private void replaceItems(
            Roadmap roadmap,
            List<Long> courseIds,
            Long organizationId
    ) {

        List<Course> courses =
                courseRepository.findAllById(
                        courseIds
                );

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

        roadmap.getItems()
                .clear();

        int position = 1;

        for (Long courseId : courseIds) {

            RoadmapItem item =
                    RoadmapItem.builder()
                            .roadmap(
                                    roadmap
                            )
                            .course(
                                    courseMap.get(courseId)
                            )
                            .position(
                                    position++
                            )
                            .build();

            roadmap.getItems()
                    .add(
                            item
                    );
        }
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
                                        .equals(
                                                organizationId
                                        )
                        );

        if (hasCourseFromAnotherOrganization) {
            throw new ConflictException(
                    "Roadmap courses must belong to the organization"
            );
        }
    }
}
