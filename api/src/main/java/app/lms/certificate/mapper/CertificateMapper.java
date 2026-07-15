package app.lms.certificate.mapper;

import app.lms.certificate.dto.CertificateResponse;
import app.lms.certificate.model.Certificate;
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
                .issuedAt(certificate.getIssuedAt())
                .organizationName(certificate.getCourse().getOrganization().getName())
                .build();
    }

}
