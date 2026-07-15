package app.lms.certificate.service;

import app.lms.certificate.dto.CertificateResponse;
import app.lms.certificate.mapper.CertificateMapper;
import app.lms.certificate.model.Certificate;
import app.lms.certificate.repository.CertificateRepository;
import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.NotFoundException;
import app.lms.course.model.Course;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CertificateService {

    private final CertificateRepository certificateRepository;

    private final CertificateMapper certificateMapper;

    public String generate() {

        return UUID.randomUUID()
                .toString()
                .replace("-","")
                .substring(0,16)
                .toUpperCase();
    }

    @Transactional
    public void issueCertificate(
            Course course,
            User user
    ){

        if(certificateRepository.existsByCourseIdAndUserId(
                course.getId(),
                user.getId()
        ))
            throw new BadRequestException("You have certificate for this course");


        String code = generate();

        Certificate certificate =
                Certificate.builder()
                        .code(code)
                        .course(course)
                        .user(user)
                        .issuedAt(LocalDateTime.now())
                        .build();

        certificateRepository.save(certificate);

    }

    public CertificateResponse getByCode(
            String code
    ){

        Certificate certificate = certificateRepository.findByCode(code)
                .orElseThrow(()->
                        new BadRequestException(
                                "Certificate not found or error in code"
                        ));

        return certificateMapper.toResponse(
                certificate
        );

    }
    public Page<CertificateResponse> myCertificates(
            User user,
            Pageable pageable
    ) {

        return certificateRepository
                .findAllByUserId(
                        user.getId(),
                        pageable
                )
                .map(certificateMapper::toResponse);
    }

}