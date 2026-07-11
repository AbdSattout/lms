package app.lms.media.model;

import app.lms.common.model.BaseEntity;
import app.lms.course.model.Course;
import app.lms.media.enums.FileType;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(
        name = "course_media",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_course_media_course_name",
                        columnNames = {"course_id", "name"}
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

    private String name;

    private String url;

    private String fileId;

    @Enumerated(EnumType.STRING)
    private FileType type;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "course_id",
            nullable = false
    )
    private Course course;
}