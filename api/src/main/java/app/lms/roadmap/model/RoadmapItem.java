package app.lms.roadmap.model;

import app.lms.common.model.BaseEntity;
import app.lms.course.model.Course;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(
        name = "roadmap_items",
        uniqueConstraints = {
                @UniqueConstraint(
                        columnNames = {
                                "roadmap_id",
                                "course_id"
                        }
                )
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RoadmapItem extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "roadmap_id", nullable = false)
    private Roadmap roadmap;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    @Column(nullable = false)
    private Integer position;
}
