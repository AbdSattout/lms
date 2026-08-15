package app.lms.gamification.service;

import app.lms.billing.service.UserPlanBillingService;
import app.lms.email.service.EmailDeliveryService;
import app.lms.gamification.model.MonthlyScoreboardPremiumAward;
import app.lms.gamification.repository.MonthlyScoreboardPremiumAwardRepository;
import app.lms.gamification.repository.UserActivityDayRepository;
import app.lms.gamification.repository.projection.MonthlyScoreboardWinnerRow;
import app.lms.user.model.User;
import app.lms.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.PageRequest;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.temporal.TemporalAdjusters;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class MonthlyScoreboardPremiumAwardService {

    private static final int WINNER_LIMIT = 3;

    private final UserActivityDayRepository userActivityDayRepository;
    private final MonthlyScoreboardPremiumAwardRepository awardRepository;
    private final UserRepository userRepository;
    private final UserPlanBillingService userPlanBillingService;
    private final EmailDeliveryService emailDeliveryService;

    @Value("${app.scheduler.zone:Europe/Istanbul}")
    private String schedulerZone;

    @Value("${app.scoreboard.monthly-awards.premium-months:1}")
    private long premiumMonths;

    @Value("${app.email-otp.app-name:MSAR LMS Center}")
    private String appName;

    @Scheduled(
            cron = "${app.scoreboard.monthly-awards.cron:0 10 0 1 * *}",
            zone = "${app.scheduler.zone:Europe/Istanbul}"
    )
    @Transactional
    public void awardPreviousMonthWinners() {

        LocalDate today =
                LocalDate.now(
                        ZoneId.of(schedulerZone)
                );

        LocalDate periodFrom =
                today.minusMonths(1)
                        .withDayOfMonth(1);

        awardMonth(
                periodFrom,
                today.withDayOfMonth(1)
                        .atStartOfDay()
        );
    }

    @Transactional
    public void awardMonth(
            LocalDate periodFrom,
            LocalDateTime premiumStartedAt
    ) {

        LocalDate periodTo =
                periodFrom.with(
                        TemporalAdjusters.lastDayOfMonth()
                );

        LocalDateTime premiumExpiresAt =
                premiumStartedAt.plusMonths(
                        Math.max(
                                1,
                                premiumMonths
                        )
                );

        List<MonthlyScoreboardWinnerRow> winners =
                userActivityDayRepository.findMonthlyScoreboardWinners(
                        periodFrom,
                        periodTo,
                        PageRequest.of(
                                0,
                                WINNER_LIMIT
                        )
                );

        if (winners.isEmpty()) {
            log.info(
                    "No monthly scoreboard winners for {} to {}",
                    periodFrom,
                    periodTo
            );
            return;
        }

        for (int index = 0; index < winners.size(); index++) {
            awardWinner(
                    winners.get(index),
                    index + 1,
                    periodFrom,
                    periodTo,
                    premiumStartedAt,
                    premiumExpiresAt
            );
        }
    }

    private void awardWinner(
            MonthlyScoreboardWinnerRow winner,
            int rank,
            LocalDate periodFrom,
            LocalDate periodTo,
            LocalDateTime premiumStartedAt,
            LocalDateTime premiumExpiresAt
    ) {

        MonthlyScoreboardPremiumAward award =
                awardRepository
                        .findByPeriodFromAndPeriodToAndRank(
                                periodFrom,
                                periodTo,
                                rank
                        )
                        .orElseGet(() ->
                                createAward(
                                        winner,
                                        rank,
                                        periodFrom,
                                        periodTo,
                                        premiumStartedAt,
                                        premiumExpiresAt
                                )
                        );

        if (award.getEmailSentAt() == null) {
            sendAwardEmail(award);
        }
    }

    private MonthlyScoreboardPremiumAward createAward(
            MonthlyScoreboardWinnerRow winner,
            int rank,
            LocalDate periodFrom,
            LocalDate periodTo,
            LocalDateTime premiumStartedAt,
            LocalDateTime premiumExpiresAt
    ) {

        User user =
                userRepository
                        .findById(winner.getUserId())
                        .orElseThrow();

        userPlanBillingService.grantPremiumAward(
                user,
                premiumStartedAt,
                premiumExpiresAt
        );

        MonthlyScoreboardPremiumAward award =
                MonthlyScoreboardPremiumAward.builder()
                        .periodFrom(periodFrom)
                        .periodTo(periodTo)
                        .rank(rank)
                        .xp(winner.getPeriodXp())
                        .premiumStartedAt(premiumStartedAt)
                        .premiumExpiresAt(premiumExpiresAt)
                        .email(winner.getEmail())
                        .user(user)
                        .build();

        MonthlyScoreboardPremiumAward savedAward =
                awardRepository.save(award);

        log.info(
                "Awarded monthly scoreboard premium. userId={}, rank={}, period={} to {}",
                user.getId(),
                rank,
                periodFrom,
                periodTo
        );

        return savedAward;
    }

    private void sendAwardEmail(
            MonthlyScoreboardPremiumAward award
    ) {

        if (!StringUtils.hasText(award.getEmail())) {
            log.info(
                    "Skipping monthly premium award email because user has no email. userId={}, rank={}",
                    award.getUser()
                            .getId(),
                    award.getRank()
            );
            return;
        }

        try {
            emailDeliveryService.sendHtml(
                    award.getEmail(),
                    "You won " + appName + " Premium",
                    plainTextEmail(award),
                    htmlEmail(award)
            );

            award.setEmailSentAt(
                    LocalDateTime.now()
            );

        } catch (RuntimeException ex) {
            log.warn(
                    "Failed to send monthly premium award email. userId={}, rank={}",
                    award.getUser()
                            .getId(),
                    award.getRank(),
                    ex
            );
        }
    }

    private String plainTextEmail(
            MonthlyScoreboardPremiumAward award
    ) {

        return """
                Congratulations!

                You finished #%d on the %s monthly scoreboard with %d XP.

                Premium is now enabled on your account until %s.

                Keep learning,
                %s
                """
                .formatted(
                        award.getRank(),
                        appName,
                        award.getXp(),
                        award.getPremiumExpiresAt()
                                .toLocalDate(),
                        appName
                );
    }

    private String htmlEmail(
            MonthlyScoreboardPremiumAward award
    ) {

        String safeAppName =
                escapeHtml(appName);

        return """
                <!doctype html>
                <html>
                <body style="margin:0;padding:0;background:#f4f7fb;font-family:Arial,Helvetica,sans-serif;color:#172033;">
                  <table role="presentation" width="100%%" cellspacing="0" cellpadding="0" style="background:#f4f7fb;padding:32px 12px;">
                    <tr>
                      <td align="center">
                        <table role="presentation" width="100%%" cellspacing="0" cellpadding="0" style="max-width:560px;background:#ffffff;border:1px solid #e1e7f0;border-radius:8px;overflow:hidden;">
                          <tr>
                            <td style="padding:28px 28px 12px;">
                              <div style="font-size:14px;font-weight:700;color:#2563eb;text-transform:uppercase;letter-spacing:0.04em;">%s</div>
                              <h1 style="margin:14px 0 10px;font-size:24px;line-height:32px;color:#111827;">Premium is enabled</h1>
                              <p style="margin:0;color:#4b5563;font-size:15px;line-height:24px;">You finished in the monthly top 3 and earned a premium reward.</p>
                            </td>
                          </tr>
                          <tr>
                            <td style="padding:18px 28px 10px;">
                              <div style="background:#f8fafc;border:1px solid #dbe4ef;border-radius:8px;padding:18px;">
                                <div style="font-size:13px;color:#64748b;margin-bottom:8px;">Your result</div>
                                <div style="font-size:28px;line-height:36px;font-weight:700;color:#0f172a;">Rank #%d</div>
                                <div style="font-size:15px;line-height:24px;color:#334155;margin-top:6px;">%d XP earned</div>
                              </div>
                            </td>
                          </tr>
                          <tr>
                            <td style="padding:10px 28px 28px;">
                              <p style="margin:0;color:#334155;font-size:15px;line-height:24px;">Your premium access is active until <strong>%s</strong>.</p>
                              <p style="margin:14px 0 0;color:#64748b;font-size:13px;line-height:20px;">Keep learning and competing on the next monthly scoreboard.</p>
                            </td>
                          </tr>
                        </table>
                      </td>
                    </tr>
                  </table>
                </body>
                </html>
                """
                .formatted(
                        safeAppName,
                        award.getRank(),
                        award.getXp(),
                        award.getPremiumExpiresAt()
                                .toLocalDate()
                );
    }

    private String escapeHtml(
            String value
    ) {

        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
}
