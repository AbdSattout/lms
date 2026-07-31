package app.lms.course.CourseBan.model;

import app.lms.admin.model.Admin;
import app.lms.common.model.BaseEntity;
import app.lms.course.model.Course;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "course_moderation")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CourseModeration extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    private Course course;

    @ManyToOne
    private Admin bannedBy;

    @Column(columnDefinition = "TEXT")
    private String reason;

}
