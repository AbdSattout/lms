package app.lms.courceEnrollment.model;

import app.lms.block.model.Block;
import app.lms.courceEnrollment.enums.EnrollmentStatus;
import app.lms.course.model.Course;
import app.lms.lesson.model.Lesson;
import app.lms.user.model.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "course_enrollments",
        uniqueConstraints = {
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
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CourseEnrollment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "user_id",
            nullable = false
    )
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "course_id",
            nullable = false
    )
    private Course course;

    private LocalDateTime enrolledAt;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private EnrollmentStatus status;

    private Integer progressPercentage;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "current_lesson_id")
    private Lesson currentLesson;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "current_block_id")
    private Block currentBlock;

    private LocalDateTime completedAt;

    @PrePersist
    public void onEnroll() {

        enrolledAt = LocalDateTime.now();

        if (progressPercentage == null) {
            progressPercentage = 0;
        }
    }
}
