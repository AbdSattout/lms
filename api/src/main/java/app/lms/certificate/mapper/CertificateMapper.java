package app.lms.certificate.mapper;

import app.lms.certificate.dto.CertificateResponse;
import app.lms.certificate.model.Certificate;
import app.lms.common.dto.BaseEntityResponse;
import app.lms.config.WebAppProperties;
import app.lms.organization.mapper.OrganizationMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class CertificateMapper {

    private final OrganizationMapper organizationMapper;

    private final WebAppProperties webAppProperties;

    public CertificateResponse toResponse(
            Certificate certificate
    ) {

        return CertificateResponse.builder()
                .certificateCode(
                        certificate.getCode()
                )
                .studentName(
                        certificate.getUser().getName()
                )
                .courseName(
                        certificate.getCourse().getTitle()
                )
                .organization(
                        organizationMapper.toSummaryResponse(
                                certificate.getCourse()
                                        .getOrganization()
                        )
                )
                .finalQuizScore(
                        certificate.getFinalQuizScore()
                )
                .finalQuizTotal(
                        certificate.getFinalQuizTotal()
                )
                .finalQuizPercentage(
                        certificate.getFinalQuizPercentage()
                )
                .grade(
                        certificate.getGrade()
                )
                .previewUrl(
                        webAppProperties.url(
                                "/api/certificates/" +
                                        certificate.getCode() +
                                        "?type=png"
                        )
                )
                .pdfUrl(
                        webAppProperties.url(
                                "/api/certificates/" +
                                        certificate.getCode() +
                                        "?type=pdf"
                        )
                )
                .baseEntity(
                        BaseEntityResponse.from(
                                certificate
                        )
                )
                .build();
    }
}