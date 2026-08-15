package app.lms.certificate.service;

import app.lms.certificate.dto.CertificateResponse;
import app.lms.certificate.enums.CertificateGrade;
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
    public CertificateResponse issueCertificate(
            Course course,
            User user,
            Integer finalQuizScore,
            Integer finalQuizTotal
    ){

        if(certificateRepository.existsByCourseIdAndUserId(
                course.getId(),
                user.getId()
        ))
            throw new BadRequestException("You have certificate for this course");


        String code = generate();
        Integer finalQuizPercentage =
                calculatePercentage(
                        finalQuizScore,
                        finalQuizTotal
                );

        Certificate certificate =
                Certificate.builder()
                        .code(code)
                        .course(course)
                        .user(user)
                        .finalQuizScore(finalQuizScore)
                        .finalQuizTotal(finalQuizTotal)
                        .finalQuizPercentage(finalQuizPercentage)
                        .grade(gradeFor(finalQuizPercentage))
                        .build();

        Certificate savedCertificate =
                certificateRepository.save(certificate);

        return certificateMapper.toResponse(
                savedCertificate
        );
    }

    private Integer calculatePercentage(
            Integer score,
            Integer total
    ) {

        if (score == null || total == null || total <= 0) {
            return 0;
        }

        return (int) Math.round(
                score * 100.0 / total
        );
    }

    private CertificateGrade gradeFor(
            Integer percentage
    ) {

        if (percentage >= 90) {
            return CertificateGrade.EXCELLENT;
        }

        if (percentage >= 75) {
            return CertificateGrade.VERY_GOOD;
        }

        if (percentage >= 60) {
            return CertificateGrade.GOOD;
        }

        return CertificateGrade.BASIC;
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
