package app.lms.certificate.mapper;

import app.lms.certificate.dto.CertificateResponse;
import app.lms.certificate.model.Certificate;
import app.lms.common.dto.BaseEntityResponse;
import app.lms.organization.mapper.OrganizationMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class CertificateMapper {

    private final OrganizationMapper organizationMapper;

    @Value("${app.web-app.base-url:https://lmscenter.vercel.app}")
    private String webAppBaseUrl;

    public CertificateResponse toResponse(
            Certificate certificate
    ) {

        String baseUrl =
                stripTrailingSlash(webAppBaseUrl);

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
                        baseUrl + "/api/certificates/" +
                                certificate.getCode() +
                                "?type=png"
                )
                .pdfUrl(
                        baseUrl + "/api/certificates/" +
                                certificate.getCode() +
                                "?type=pdf"
                )
                .baseEntity(
                        BaseEntityResponse.from(
                                certificate
                        )
                )
                .build();
    }

    private String stripTrailingSlash(
            String url
    ) {

        if (url == null) {
            return "";
        }

        return url.replaceAll("/+$", "");
    }
}