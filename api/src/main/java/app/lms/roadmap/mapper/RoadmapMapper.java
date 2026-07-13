package app.lms.roadmap.mapper;

import app.lms.course.mapper.CourseMapper;
import app.lms.course.enums.CourseStatus;
import app.lms.roadmap.dto.RoadmapItemResponse;
import app.lms.roadmap.dto.RoadmapResponse;
import app.lms.roadmap.model.Roadmap;
import app.lms.roadmap.model.RoadmapItem;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Comparator;

@Component
@RequiredArgsConstructor
public class RoadmapMapper {

    private final CourseMapper courseMapper;

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

        return new RoadmapResponse(
                roadmap.getId(),
                roadmap.getOrganization().getId(),
                roadmap.getOrganization().getSlug(),
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
                        .map(this::toItemResponse)
                        .toList()
        );
    }

    private RoadmapItemResponse toItemResponse(
            RoadmapItem item
    ) {

        return new RoadmapItemResponse(
                item.getId(),
                item.getPosition(),
                courseMapper.toResponse(
                        item.getCourse()
                )
        );
    }
}
