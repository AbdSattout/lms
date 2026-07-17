package app.lms.placementTest.model;

import app.lms.block.model.Block;
import app.lms.common.model.BaseEntity;
import app.lms.course.model.Course;
import app.lms.user.model.User;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(
        name = "course_placement_test_attempts",
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
public class CoursePlacementTestAttempt extends BaseEntity {

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

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "current_block_id")
    private Block currentBlock;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "placed_block_id")
    private Block placedBlock;

    @Column(nullable = false)
    @Builder.Default
    private Boolean completed = false;

    @Column(nullable = false)
    @Builder.Default
    private Integer correctAnswers = 0;

    @Column(nullable = false)
    @Builder.Default
    private Integer totalAnswers = 0;
}
