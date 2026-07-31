package app.lms.report.model;

import app.lms.admin.model.Admin;
import app.lms.common.model.BaseEntity;
import app.lms.report.enums.ReportStatus;
import app.lms.report.enums.ReportTargetType;
import app.lms.user.model.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "reports")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Report extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(nullable = false)
    private User reporter;

    @ManyToOne(fetch = FetchType.LAZY)
    private Admin reviewedBy;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ReportTargetType targetType;

    @Column(nullable = false)
    private Long targetId;

    @Column(length = 1000)
    private String reason;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private ReportStatus status = ReportStatus.PENDING;

    @Column(length = 1000)
    private String adminNote;

    private LocalDateTime reviewedAt;

}
