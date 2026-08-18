package app.lms.practiceExam.model;

import app.lms.common.model.BaseEntity;
import app.lms.course.model.Course;
import app.lms.practiceExam.enums.PracticeExamStatus;
import app.lms.question.model.Question;
import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "practice_exams")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PracticeExam extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "time_limit_minutes")
    private Integer timeLimitMinutes;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, columnDefinition = "varchar(255) default 'DRAFT'")
    @Builder.Default
    private PracticeExamStatus status = PracticeExamStatus.DRAFT;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    @ManyToMany
    @JoinTable(
            name = "practice_exam_questions",
            joinColumns = @JoinColumn(name = "practice_exam_id"),
            inverseJoinColumns = @JoinColumn(name = "question_id")
    )
    @OrderColumn(name = "position")
    @Builder.Default
    private List<Question> questions = new ArrayList<>();
}
