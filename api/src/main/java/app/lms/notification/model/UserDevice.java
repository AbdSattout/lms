package app.lms.notification.model;

import app.lms.common.model.BaseEntity;
import app.lms.user.model.User;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "user_devices",
        uniqueConstraints =
                @UniqueConstraint(
                        columnNames = "token"
                )
)
@Getter
@Setter
@NoArgsConstructor
public class UserDevice extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "user_id",
            nullable = false
    )
    private User user;

    @Column(
            nullable = false,
            unique = true
    )
    private String token;

    @Column(nullable = false)
    private boolean active = true;

    private LocalDateTime lastUsedAt;
}
