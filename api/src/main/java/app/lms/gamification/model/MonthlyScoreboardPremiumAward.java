package app.lms.gamification.model;

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
import jakarta.persistence.UniqueConstraint;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(
        name = "monthly_scoreboard_premium_awards",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_monthly_scoreboard_awards_period_rank",
                        columnNames = {
                                "period_from",
                                "period_to",
                                "award_rank"
                        }
                ),
                @UniqueConstraint(
                        name = "uk_monthly_scoreboard_awards_period_user",
                        columnNames = {
                                "period_from",
                                "period_to",
                                "user_id"
                        }
                )
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MonthlyScoreboardPremiumAward extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private LocalDate periodFrom;

    @Column(nullable = false)
    private LocalDate periodTo;

    @Column(name = "award_rank", nullable = false)
    private Integer rank;

    @Column(nullable = false)
    private Long xp;

    @Column(nullable = false)
    private LocalDateTime premiumStartedAt;

    @Column(nullable = false)
    private LocalDateTime premiumExpiresAt;

    private String email;

    private LocalDateTime emailSentAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
}
