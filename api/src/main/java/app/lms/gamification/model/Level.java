package app.lms.gamification.model;

import app.lms.common.model.BaseEntity;
import app.lms.gamification.enums.LevelTier;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(
        name = "levels",
        uniqueConstraints = {
                @UniqueConstraint(
                        columnNames = "level_number"
                )
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Level extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(
            name = "level_number",
            nullable = false
    )
    private Integer levelNumber;

    @Column(nullable = false)
    private Integer requiredXp;

    @Column(nullable = false)
    private String title;
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private LevelTier tier;
}
