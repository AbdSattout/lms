package app.lms.report.service;

import app.lms.report.dto.CreateReportRequest;
import app.lms.report.dto.ReportResponse;
import app.lms.report.enums.ReportStatus;
import app.lms.report.mapper.ReportMapper;
import app.lms.report.model.Report;
import app.lms.report.repository.ReportRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Transactional
public class ReportService {

    private final ReportRepository reportRepository;

    private final ReportMapper reportMapper;

    private final ReportAccessService reportAccessService;

    public ReportResponse create(
            CreateReportRequest request,
            User reporter
    ) {

        Long targetId =
                reportAccessService.resolveTargetId(
                        request
                );

        reportAccessService.validateNotReportingYourself(
                reporter,
                request.targetType(),
                targetId
        );

        reportAccessService.validateDuplicate(
                reporter,
                request.targetType(),
                targetId
        );

        Report report = Report.builder()
                .reporter(reporter)
                .targetType(request.targetType())
                .targetId(targetId)
                .reason(request.reason())
                .status(ReportStatus.PENDING)
                .build();

        reportRepository.save(report);

        return reportMapper.toResponse(report);
    }

    @Transactional()
    public Page<ReportResponse> getMyReports(
            User user,
            Pageable pageable
    ) {

        return reportRepository
                .findAllByReporterId(
                        user.getId(),
                        pageable
                )
                .map(reportMapper::toResponse);
    }

}
