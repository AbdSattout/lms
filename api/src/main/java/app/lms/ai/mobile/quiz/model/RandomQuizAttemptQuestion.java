package app.lms.ai.mobile.quiz.model;

import app.lms.common.model.BaseEntity;
import app.lms.common.quiz.interfaces.GradableQuizQuestion;
import app.lms.question.model.Question;
import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Entity
@Table(name = "random_quiz_attempt_questions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RandomQuizAttemptQuestion extends BaseEntity implements GradableQuizQuestion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String content;

    @ElementCollection
    @CollectionTable(
            name = "random_quiz_attempt_question_options",
            joinColumns = @JoinColumn(name = "attempt_question_id")
    )
    @Column(name = "option_value", nullable = false, columnDefinition = "TEXT")
    private List<String> options;

    @Column(nullable = false)
    private Integer correctAnswerIndex;

    private Integer selectedAnswerIndex;

    private Boolean correct;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "source_question_id", nullable = false)
    private Question sourceQuestion;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "attempt_id", nullable = false)
    private RandomQuizAttempt attempt;

    @Override
    public Long gradingQuestionId() {
        return getId();
    }
}
