package app.lms.randomquiz.model;

import app.lms.common.model.BaseEntity;
import app.lms.common.quiz.interfaces.CompletableQuizAttempt;
import app.lms.course.model.Course;
import app.lms.question.enums.QuestionDifficulty;
import app.lms.user.model.User;
import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "bank_random_quiz_attempts")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BankRandomQuizAttempt extends BaseEntity implements CompletableQuizAttempt {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private QuestionDifficulty difficulty;

    @Column(nullable = false)
    @Builder.Default
    private Boolean completed = false;

    private Integer score;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @OneToMany(
            mappedBy = "attempt",
            cascade = CascadeType.ALL,
            orphanRemoval = true
    )
    @Builder.Default
    private List<BankRandomQuizAttemptQuestion> questions = new ArrayList<>();
}
