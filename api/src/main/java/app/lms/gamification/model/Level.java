package app.lms.gamification.model;

import app.lms.common.model.BaseEntity;
import app.lms.gamification.enums.LevelTier;
import app.lms.gamification.enums.LevelUnlockType;
import jakarta.persistence.*;
import lombok.*;

import java.util.List;

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

    private String badgeIcon;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private LevelTier tier;

    @ElementCollection(targetClass = LevelUnlockType.class)
    @CollectionTable(
            name = "level_unlocks",
            joinColumns = @JoinColumn(name = "level_id")
    )
    @Enumerated(EnumType.STRING)
    @Column(name = "unlock_type")
    private List<LevelUnlockType> unlockTypes;
}
