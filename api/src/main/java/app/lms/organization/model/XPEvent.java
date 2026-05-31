package app.lms.organization.model;

import app.lms.courceEnrollment.enums.XPEventType;
import app.lms.user.model.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "xp_events")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class XPEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    private XPEventType type;

    private Long referenceId;

    private Integer amount;

    private LocalDateTime createdAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @PrePersist
    public void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
