package app.lms.course.CourseBan.model;

import app.lms.admin.model.Admin;
import app.lms.common.model.BaseEntity;
import app.lms.course.model.Course;
import app.lms.user.model.User;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(
        name = "course_bans",
        uniqueConstraints = @UniqueConstraint(
                columnNames = {
                        "course_id",
                        "user_id"
                }
        )
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CourseBan extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(nullable = false)
    private Course course;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(nullable = true)
    private Admin bannedByAppAdmins;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(nullable = true)
    private User bannedByOrgAdmins;

    @Column(columnDefinition = "TEXT")
    private String reason;
}
