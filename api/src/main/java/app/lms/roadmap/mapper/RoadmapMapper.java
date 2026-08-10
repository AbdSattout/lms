package app.lms.roadmap.mapper;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.enrollment.model.CourseEnrollment;
import app.lms.course.model.Course;
import app.lms.course.mapper.CourseMapper;
import app.lms.course.enums.CourseStatus;
import app.lms.organization.model.Organization;
import app.lms.organization.mapper.OrganizationMapper;
import app.lms.roadmap.dto.RoadmapItemResponse;
import app.lms.roadmap.dto.RoadmapResponse;
import app.lms.roadmap.enums.RoadmapFollowStatus;
import app.lms.roadmap.model.Roadmap;
import app.lms.roadmap.model.RoadmapItem;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class RoadmapMapper {

    private final CourseMapper courseMapper;
    private final OrganizationMapper organizationMapper;

    public Roadmap toEntity(
            Organization organization,
            String name,
            String description,
            List<Course> courses
    ) {

        Roadmap roadmap =
                Roadmap.builder()
                        .name(name)
                        .description(description)
                        .organization(organization)
                        .build();

        replaceItems(
                roadmap,
                courses
        );

        return roadmap;
    }

    public void replaceItems(
            Roadmap roadmap,
            List<Course> courses
    ) {

        Map<Long, RoadmapItem> existingItemsByCourseId =
                roadmap.getItems()
                        .stream()
                        .collect(
                                Collectors.toMap(
                                        item -> item.getCourse().getId(),
                                        item -> item
                                )
                        );

        Set<Long> requestedCourseIds =
                courses.stream()
                        .map(Course::getId)
                        .collect(Collectors.toSet());

        roadmap.getItems()
                .removeIf(item ->
                        !requestedCourseIds.contains(
                                item.getCourse().getId()
                        )
                );

        int position = 1;

        for (Course course : courses) {
            RoadmapItem item =
                    existingItemsByCourseId.get(
                            course.getId()
                    );

            if (item == null) {
                item =
                        toItemEntity(
                                roadmap,
                                course,
                                position
                        );

                roadmap.getItems()
                        .add(item);
            } else {
                item.setPosition(position);
            }

            position++;
        }
    }

    public RoadmapResponse toResponse(
            Roadmap roadmap
    ) {

        return toResponse(
                roadmap,
                false
        );
    }

    public RoadmapResponse toResponse(
            Roadmap roadmap,
            boolean publishedOnly
    ) {

        return toResponse(
                roadmap,
                publishedOnly,
                Map.of()
        );
    }

    public RoadmapResponse toResponse(
            Roadmap roadmap,
            boolean publishedOnly,
            Map<Long, CourseEnrollment> enrollmentsByCourseId
    ) {

        return toResponse(
                roadmap,
                publishedOnly,
                enrollmentsByCourseId,
                RoadmapFollowStatus.NOT_FOLLOWING
        );
    }

    public RoadmapResponse toResponse(
            Roadmap roadmap,
            boolean publishedOnly,
            Map<Long, CourseEnrollment> enrollmentsByCourseId,
            RoadmapFollowStatus followStatus
    ) {

        return new RoadmapResponse(
                roadmap.getId(),
                roadmap.getName(),
                roadmap.getDescription(),
                roadmap.getStatus(),
                organizationMapper.ToResponse(
                        roadmap.getOrganization()
                ),
                roadmap.getItems()
                        .stream()
                        .filter(item ->
                                !publishedOnly ||
                                        item.getCourse().getStatus()
                                                == CourseStatus.PUBLISHED
                        )
                        .sorted(
                                Comparator.comparing(
                                        RoadmapItem::getPosition
                                )
                        )
                        .map(item ->
                                toItemResponse(
                                        item,
                                        enrollmentsByCourseId
                                )
                        )
                        .toList(),
                followStatus,
                BaseEntityResponse.from(roadmap)
        );
    }

    public RoadmapResponse toMobileResponse(
            Roadmap roadmap,
            Map<Long, CourseEnrollment> enrollmentsByCourseId,
            RoadmapFollowStatus followStatus
    ) {

        return toResponse(
                roadmap,
                true,
                enrollmentsByCourseId,
                followStatus
        );
    }

    private RoadmapItemResponse toItemResponse(
            RoadmapItem item
    ) {

        return toItemResponse(
                item,
                Map.of()
        );
    }

    private RoadmapItemResponse toItemResponse(
            RoadmapItem item,
            Map<Long, CourseEnrollment> enrollmentsByCourseId
    ) {

        Course course =
                item.getCourse();

        return new RoadmapItemResponse(
                item.getId(),
                item.getPosition(),
                courseMapper.toResponse(
                        course,
                        enrollmentsByCourseId.get(
                                course.getId()
                        )
                ),
                BaseEntityResponse.from(item)
        );
    }

    private RoadmapItem toItemEntity(
            Roadmap roadmap,
            Course course,
            Integer position
    ) {

        return RoadmapItem.builder()
                .roadmap(roadmap)
                .course(course)
                .position(position)
                .build();
    }
}
