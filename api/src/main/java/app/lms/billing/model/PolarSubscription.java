package app.lms.billing.model;

import app.lms.common.model.BaseEntity;
import app.lms.user.model.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "polar_subscriptions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PolarSubscription extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false, unique = true)
    private String polarSubscriptionId;

    @Column(nullable = false)
    private String polarCustomerId;

    @Column(nullable = false)
    private String polarProductId;

    @Column(nullable = false)
    private String status;

    private LocalDateTime currentPeriodStart;

    private LocalDateTime currentPeriodEnd;

    @Column(nullable = false)
    @Builder.Default
    private Boolean cancelAtPeriodEnd = false;

    private LocalDateTime canceledAt;

    private LocalDateTime revokedAt;
}
