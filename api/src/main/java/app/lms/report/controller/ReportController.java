package app.lms.report.controller;

import app.lms.report.dto.CreateReportRequest;
import app.lms.report.dto.ReportResponse;
import app.lms.report.service.ReportService;
import app.lms.security.UserPrincipal;
import app.lms.user.model.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/reports")
@RequiredArgsConstructor
public class ReportController {

    private final ReportService reportService;

    @PostMapping
    public ReportResponse create(

            @Valid
            @RequestBody
            CreateReportRequest request,

            @AuthenticationPrincipal
            UserPrincipal user

    ) {

        return reportService.create(
                request,
                user.user()
        );

    }

    @GetMapping("/me")
    public Page<ReportResponse> myReports(

            @AuthenticationPrincipal
            UserPrincipal user,

            Pageable pageable

    ) {

        return reportService.getMyReports(
                user.user(),
                pageable
        );

    }

}
