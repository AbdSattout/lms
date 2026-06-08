package app.lms.block.model;

import app.lms.block.enums.BlockType;
import app.lms.common.model.BaseEntity;
import app.lms.lesson.model.Lesson;
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

    @Enumerated(EnumType.STRING)
    private BlockType type;

    @Column
    @Lob
    private String content;

    private Integer position;

    private Boolean isPublished;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lesson_id")
    private Lesson lesson;
}