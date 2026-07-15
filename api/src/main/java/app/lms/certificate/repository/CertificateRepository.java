package app.lms.certificate.repository;

import app.lms.certificate.model.Certificate;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CertificateRepository extends JpaRepository<Certificate,Long> {

    Optional<Certificate> findByCode(
            String code
    );

    boolean existsByCourseIdAndUserId(
            Long courseId,
            Long userId
    );
    Page<Certificate> findAllByUserId(
            Long userId,
            Pageable pageable
    );
}
