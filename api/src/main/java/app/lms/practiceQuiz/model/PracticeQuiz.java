package app.lms.practiceQuiz.model;

import app.lms.common.model.BaseEntity;
import app.lms.course.model.Course;
import app.lms.question.model.Question;
import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "practice_quizzes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PracticeQuiz extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    @ManyToMany
    @JoinTable(
            name = "practice_quiz_questions",
            joinColumns = @JoinColumn(name = "practice_quiz_id"),
            inverseJoinColumns = @JoinColumn(name = "question_id")
    )
    @OrderColumn(name = "position")
    @Builder.Default
    private List<Question> questions = new ArrayList<>();
}