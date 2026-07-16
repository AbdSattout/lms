package app.lms.roadmap.mapper;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.courceEnrollment.model.CourseEnrollment;
import app.lms.course.model.Course;
import app.lms.course.mapper.CourseMapper;
import app.lms.course.enums.CourseStatus;
import app.lms.organization.model.Organization;
import app.lms.organization.mapper.OrganizationMapper;
import app.lms.roadmap.dto.RoadmapItemResponse;
import app.lms.roadmap.dto.RoadmapResponse;
import app.lms.roadmap.model.Roadmap;
import app.lms.roadmap.model.RoadmapItem;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Comparator;
import java.util.List;
import java.util.Map;

@Component
@RequiredArgsConstructor
public class RoadmapMapper {

    private final CourseMapper courseMapper;
    private final OrganizationMapper organizationMapper;

    public Roadmap toEntity(
            Organization organization,
            List<Course> courses
    ) {

        Roadmap roadmap =
                Roadmap.builder()
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

        roadmap.getItems()
                .clear();

        int position = 1;

        for (Course course : courses) {
            roadmap.getItems()
                    .add(
                            toItemEntity(
                                    roadmap,
                                    course,
                                    position++
                            )
                    );
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

        return new RoadmapResponse(
                roadmap.getId(),
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
                BaseEntityResponse.from(roadmap)
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
