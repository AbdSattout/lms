package app.lms.report.dto;

import app.lms.admin.dto.AdminResponse;
import app.lms.common.dto.BaseEntityResponse;
import app.lms.report.enums.ReportStatus;
import app.lms.report.enums.ReportTargetType;
import app.lms.user.dto.UserResponse;

import java.time.LocalDateTime;

public record ReportResponse(

        Long id,

        UserResponse reporter,

        ReportTargetType targetType,

        ReportTargetResponse target,

        String reason,

        ReportStatus status,

        String adminNote,

        AdminResponse adminResponse,

        BaseEntityResponse baseEntityResponse,

        LocalDateTime reviewedAt

) {
}
