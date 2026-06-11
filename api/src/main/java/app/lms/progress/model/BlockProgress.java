package app.lms.progress.model;

import app.lms.block.model.Block;
import app.lms.common.model.BaseEntity;
import app.lms.user.model.User;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(
        name = "block_progress",
        uniqueConstraints = @UniqueConstraint(
                columnNames = {"user_id", "block_id"}
        )
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BlockProgress extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Integer attempts;

    private Boolean completed;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "block_id", nullable = false)
    private Block block;
}
