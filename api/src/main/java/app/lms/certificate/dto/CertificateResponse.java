package app.lms.certificate.dto;

import app.lms.certificate.enums.CertificateGrade;
import app.lms.common.dto.BaseEntityResponse;
import lombok.Builder;

@Builder
public record CertificateResponse(

        String certificateCode,
        String studentName,
        String courseName,
        String organizationName,
        Integer finalQuizScore,
        Integer finalQuizTotal,
        Integer finalQuizPercentage,
        CertificateGrade grade,
        BaseEntityResponse baseEntity

) {}
