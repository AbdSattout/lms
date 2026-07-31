package app.lms.report.dto;

import app.lms.report.enums.ReportStatus;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record ReportReviewRequest(

        @NotNull
        ReportStatus status,

        @Size(max = 1000)
        String adminNote

) {
}
