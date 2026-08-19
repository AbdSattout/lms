package app.lms.certificate.dto;

import app.lms.certificate.enums.CertificateGrade;
import app.lms.common.dto.BaseEntityResponse;
import app.lms.organization.dto.OrganizationSummaryResponse;
import lombok.Builder;

@Builder
public record CertificateResponse(

        String certificateCode,

        String studentName,

        String courseName,

        OrganizationSummaryResponse organization,

        Integer finalQuizScore,

        Integer finalQuizTotal,

        Integer finalQuizPercentage,

        CertificateGrade grade,

        String previewUrl,

        String pdfUrl,

        BaseEntityResponse baseEntity

) {
}