package app.lms.report.mapper;

import app.lms.admin.mapper.AdminMapper;
import app.lms.common.dto.BaseEntityResponse;
import app.lms.report.dto.ReportResponse;
import app.lms.report.model.Report;
import app.lms.user.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ReportMapper {

    private final UserMapper userMapper;
    private final AdminMapper adminMapper;

    public ReportResponse   toResponse(
            Report report
    ) {

        return new ReportResponse(

                report.getId(),

                userMapper.toResponse(
                        report.getReporter()
                ),

                report.getTargetType(),

                report.getTargetId(),

                report.getReason(),

                report.getStatus(),

                report.getAdminNote(),

                adminMapper.toResponse(
                        report.getReviewedBy()
                ),

                BaseEntityResponse.from(report),

                report.getReviewedAt()
        );
    }

}
