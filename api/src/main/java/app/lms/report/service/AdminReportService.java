package app.lms.report.service;

import app.lms.admin.model.Admin;
import app.lms.admin.service.AdminModerationAccessService;
import app.lms.report.dto.ReportResponse;
import app.lms.report.dto.ReportReviewRequest;
import app.lms.report.enums.ReportStatus;
import app.lms.report.mapper.ReportMapper;
import app.lms.report.model.Report;
import app.lms.report.repository.ReportRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Transactional
public class AdminReportService {

    private final ReportRepository reportRepository;

    private final ReportAccessService reportAccessService;

    private final AdminModerationAccessService accessService;

    private final ReportMapper reportMapper;

    public ReportResponse review(
            Long reportId,
            ReportReviewRequest request,
            Long adminId
    ) {


        Admin admin =
                accessService.getAdmin(
                        adminId
                );

        accessService.validateAdmin(admin);


        Report report =
                reportAccessService.getById(reportId);

        validateStatusTransition(
                report,
                request.status()
        );

        report.setStatus(
                request.status()
        );

        report.setAdminNote(
                request.adminNote()
        );

        report.setReviewedBy(
                admin
        );

        report.setReviewedAt(
                LocalDateTime.now()
        );

        reportRepository.save(report);

        return reportMapper.toResponse(report);
    }

    @Transactional()
    public Page<ReportResponse> getAll(
            Long adminId,
            Pageable pageable
    ) {

        Admin admin =
                accessService.getAdmin(
                        adminId
                );

        accessService.validateAdmin(admin);

        return reportRepository
                .findAll(pageable)
                .map(reportMapper::toResponse);
    }

    @Transactional()
    public Page<ReportResponse> getByStatus(
            Long adminId,
            ReportStatus status,
            Pageable pageable
    ) {

        Admin admin =
                accessService.getAdmin(
                        adminId
                );

        accessService.validateAdmin(admin);

        return reportRepository
                .findAllByStatus(
                        status,
                        pageable
                )
                .map(reportMapper::toResponse);
    }

    private void validateStatusTransition(
            Report report,
            ReportStatus newStatus
    ) {

        ReportStatus current = report.getStatus();

        switch (current) {

            case PENDING -> {

                if (newStatus != ReportStatus.UNDER_REVIEW) {
                    throw new IllegalArgumentException(
                            "Pending reports can only move to UNDER_REVIEW."
                    );
                }

            }

            case UNDER_REVIEW -> {

                if (newStatus != ReportStatus.RESOLVED &&
                        newStatus != ReportStatus.REJECTED) {

                    throw new IllegalArgumentException(
                            "Under review reports can only be RESOLVED or REJECTED."
                    );
                }

            }

            case RESOLVED, REJECTED ->
                    throw new IllegalStateException(
                            "This report has already been reviewed."
                    );

        }

    }

}
