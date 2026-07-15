package app.lms.certificate.dto;

import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record CertificateResponse(

        String certificateCode,
        String studentName,
        String courseName,
        String organizationName,
        LocalDateTime issuedAt

) {}
