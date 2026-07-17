package app.lms.certificate.model;

import app.lms.certificate.enums.CertificateGrade;
import app.lms.common.model.BaseEntity;
import app.lms.course.model.Course;
import app.lms.user.model.User;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(
        name = "certificates",
        uniqueConstraints = {
                @UniqueConstraint(
                        columnNames = "code"
                ),
                @UniqueConstraint(
                        columnNames = {
                                "user_id",
                                "course_id"
                        }
                )
        }
)
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Certificate extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String code;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    @Column(nullable = false)
    private Integer finalQuizScore;

    @Column(nullable = false)
    private Integer finalQuizTotal;

    @Column(nullable = false)
    private Integer finalQuizPercentage;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CertificateGrade grade;
}
