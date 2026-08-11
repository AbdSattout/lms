package app.lms.certificate.controller;

import app.lms.certificate.dto.CertificateResponse;
import app.lms.certificate.service.CertificateService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
@RestController
@RequestMapping("/certificates")
@RequiredArgsConstructor
public class CertificateController {

    private final CertificateService certificateService;

    @GetMapping("/{code}")
    public ResponseEntity<CertificateResponse> getCertificate(

            @PathVariable
            String code
    ){
        return ResponseEntity.ok(
                certificateService.getByCode(code)
        );

    }
    @GetMapping("/me")
    public ResponseEntity<Page<CertificateResponse>> myCertificates(

            Pageable pageable,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                certificateService.myCertificates(
                        principal.user(),
                        pageable
                )
        );
    }

}
