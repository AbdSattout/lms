package app.lms.course.model;

import app.lms.chapter.model.Chapter;
import app.lms.course.enums.CourseStatus;
import app.lms.common.model.BaseEntity;
import app.lms.organization.model.Organization;
import app.lms.practiceQuiz.model.PracticeQuiz;
import app.lms.quiz.model.Quiz;
import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Entity
@Table(
        name = "courses",
        uniqueConstraints = {
                @UniqueConstraint(
                        columnNames = {
                                "organization_id",
                                "slug"
                        }
                )
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Course extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false )
    private String slug;

    private String coverUrl;

    private String coverFileId;

    @OneToMany(
            mappedBy = "course",
            cascade = CascadeType.ALL,
            orphanRemoval = true
    )
    private List<Chapter> chapters;

    @Column
    private String description;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "organization_id")
    private Organization organization;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CourseStatus status;

    @OneToOne(mappedBy = "course", cascade = CascadeType.ALL)
    private Quiz quiz;

    @OneToMany(
            mappedBy = "course",
            cascade = CascadeType.ALL,
            orphanRemoval = true
    )
    private List<PracticeQuiz> practiceQuizzes;

}
