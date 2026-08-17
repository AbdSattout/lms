package app.lms.report.dto;

import app.lms.report.enums.ReportTargetType;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CreateReportRequest(

        @NotNull
        ReportTargetType targetType,

        Long userId,

        Long organizationId,

        Long courseId,

        Long postId,

        Long commentId,

        @NotNull
        @Size(max = 1000)
        String reason

) {
}
