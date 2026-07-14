package app.lms.media.model;

import app.lms.common.model.BaseEntity;
import app.lms.course.model.Course;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(
        name = "course_media",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_course_media_course_organization_media",
                        columnNames = {"course_id", "organization_media_id"}
                )
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CourseMedia extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "course_id",
            nullable = false
    )
    private Course course;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "organization_media_id"
    )
    private OrganizationMedia organizationMedia;
}
