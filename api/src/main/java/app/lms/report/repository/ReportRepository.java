package app.lms.report.repository;

import app.lms.report.enums.ReportStatus;
import app.lms.report.enums.ReportTargetType;
import app.lms.report.model.Report;
import app.lms.user.model.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;


public interface ReportRepository
        extends JpaRepository<Report, Long> {

    Page<Report> findAllByStatus(
            ReportStatus status,
            Pageable pageable
    );


    boolean existsByReporterAndTargetTypeAndTargetId(
            User reporter,
            ReportTargetType targetType,
            Long targetId
    );

    Page<Report> findAllByReporterId(
            Long reporterId,
            Pageable pageable
    );
}
