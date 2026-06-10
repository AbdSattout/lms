package app.lms.block.model;

import app.lms.common.model.BaseEntity;
import app.lms.lesson.model.Lesson;
import app.lms.question.model.Question;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "blocks")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Block extends BaseEntity{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;



    @Column
    private String content;




    private Integer position;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lesson_id")
    private Lesson lesson;


    @OneToOne(
            mappedBy = "block",
            cascade = CascadeType.ALL,
            orphanRemoval = true
    )
    private Question question;
}