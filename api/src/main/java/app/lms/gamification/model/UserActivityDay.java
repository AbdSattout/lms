package app.lms.gamification.model;

import app.lms.common.model.BaseEntity;
import app.lms.user.model.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(
        name = "user_activity_days",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_user_activity_days_user_date",
                        columnNames = {"user_id", "activity_date"}
                )
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserActivityDay extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "user_id",
            nullable = false
    )
    private User user;

    @Column(
            name = "activity_date",
            nullable = false
    )
    private LocalDate activityDate;

    @Column(nullable = false)
    private Integer xpEarned;

    @Column(nullable = false)
    private Integer completedBlocks;

    @Column(nullable = false)
    private Integer completedLessons;

    @Column(nullable = false)
    private Integer completedChapters;

    @Column(nullable = false)
    private Integer completedCourses;

    @Column(nullable = false)
    private Integer completedPracticeQuizzes;

    @Column(nullable = false)
    private Integer completedFinalQuizzes;

    @Column(nullable = false)
    private Integer completedQuizzes;

    @Column(nullable = false)
    private Integer correctQuestions;

    @Column(nullable = false)
    private Integer enrollments;
}
