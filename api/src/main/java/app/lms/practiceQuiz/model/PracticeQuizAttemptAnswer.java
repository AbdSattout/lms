package app.lms.practiceQuiz.model;

import app.lms.common.model.BaseEntity;
import app.lms.question.model.Question;
import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Entity
@Table(name = "practice_quiz_attempt_answers")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PracticeQuizAttemptAnswer extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String content;

    @ElementCollection
    @CollectionTable(
            name = "practice_quiz_attempt_answer_options",
            joinColumns = @JoinColumn(name = "attempt_answer_id")
    )
    @Column(name = "option_value", nullable = false)
    private List<String> options;

    @Column(nullable = false)
    private Integer correctAnswerIndex;

    @Column(nullable = false)
    private Integer selectedAnswerIndex;

    @Column(nullable = false)
    private Boolean correct;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "source_question_id", nullable = false)
    private Question sourceQuestion;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "attempt_id", nullable = false)
    private PracticeQuizAttempt attempt;
}