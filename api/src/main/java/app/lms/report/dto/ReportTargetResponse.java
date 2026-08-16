package app.lms.report.dto;

public record ReportTargetResponse(

        Long userId,

        Long organizationId,

        Long courseId,

        Long postId,

        Long commentId,

        boolean exists

) {
}
