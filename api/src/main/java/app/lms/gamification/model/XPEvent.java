package app.lms.gamification.model;

import app.lms.common.model.BaseEntity;
import app.lms.gamification.enums.XPEventType;
import app.lms.user.model.User;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "xp_events")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class XPEvent extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    private XPEventType type;

    private Long referenceId;

    private Integer amount;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;
}
