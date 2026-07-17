package app.lms.certificate.mapper;

import app.lms.certificate.dto.CertificateResponse;
import app.lms.certificate.model.Certificate;
import app.lms.common.dto.BaseEntityResponse;
import org.springframework.stereotype.Component;

@Component
public class CertificateMapper {

    public CertificateResponse toResponse(
            Certificate certificate
    ) {

        return CertificateResponse.builder()
                .certificateCode(certificate.getCode())
                .studentName(certificate.getUser().getName())
                .courseName(certificate.getCourse().getTitle())
                .organizationName(certificate.getCourse().getOrganization().getName())
                .finalQuizScore(certificate.getFinalQuizScore())
                .finalQuizTotal(certificate.getFinalQuizTotal())
                .finalQuizPercentage(certificate.getFinalQuizPercentage())
                .grade(certificate.getGrade())
                .baseEntity(BaseEntityResponse.from(certificate))
                .build();
    }

}
