package app.lms.organization.model;

import app.lms.common.model.BaseEntity;
import app.lms.course.model.Course;
import app.lms.organization.emums.QuestionDifficulty;
import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Entity
@Table(name = "questions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Question extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(columnDefinition = "TEXT")
    private String content;

    @ElementCollection
    @CollectionTable(
            name = "question_options",
            joinColumns = @JoinColumn(name = "question_id")
    )
    @Column(name = "option_value")
    private List<String> options;

    private Integer correctAnswerIndex;

    @Enumerated(EnumType.STRING)
    private QuestionDifficulty difficulty;

    private boolean shuffleOptions;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id")
    private Course course;
}
