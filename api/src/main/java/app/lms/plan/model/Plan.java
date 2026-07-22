package app.lms.plan.model;

import app.lms.common.model.BaseEntity;
import app.lms.plan.enums.PlanCode;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Entity
@Table(name = "plans")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Plan extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, unique = true)
    private PlanCode code;

    @Column(nullable = false)
    private String name;

    @Column
    private String description;

    @Column(nullable = false)
    @Builder.Default
    private Boolean defaultPlan = false;

    @Column(nullable = false, precision = 4, scale = 2)
    @Builder.Default
    private BigDecimal xpMultiplier = BigDecimal.ONE;

    private Integer weeklyAiQuizLimit;

    private Integer weeklyCourseEnrollmentLimit;

    private Integer activeRoadmapFollowLimit;

    private Integer randomQuizPerCourseLimit;

    private Long organizationStorageLimitBytes;

    private Integer organizationLimit;

    private Integer dailyAiToolLimit;
}
