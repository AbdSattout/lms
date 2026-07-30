package app.lms.report.controller;

import app.lms.admin.model.Admin;
import app.lms.admin.security.AdminPrincipal;
import app.lms.report.dto.ReportResponse;
import app.lms.report.dto.ReportReviewRequest;
import app.lms.report.enums.ReportStatus;
import app.lms.report.service.AdminReportService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/admin/reports")
@RequiredArgsConstructor
public class AdminReportController {

    private final AdminReportService adminReportService;

    @PatchMapping("/{reportId}")
    public ReportResponse review(

            @PathVariable
            Long reportId,

            @Valid
            @RequestBody
            ReportReviewRequest request,

            @AuthenticationPrincipal
            AdminPrincipal admin

    ) {

        return adminReportService.review(
                reportId,
                request,
                admin.getId()
        );

    }
    @GetMapping
    public Page<ReportResponse> getAll(
            Pageable pageable,

            @AuthenticationPrincipal
            AdminPrincipal admin
    ) {

        return adminReportService.getAll(
                admin.getId(),
                pageable

        );

    }
    @GetMapping("/status/{status}")
    public Page<ReportResponse> getByStatus(

            @PathVariable
            ReportStatus status,

            @AuthenticationPrincipal
            AdminPrincipal admin,

            Pageable pageable

    ) {

        return adminReportService.getByStatus(
                admin.getId(),
                status,
                pageable
        );

    }

}
