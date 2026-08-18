package app.lms.organization.verification.repository;

import app.lms.organization.verification.enums.OrganizationVerificationStatus;
import app.lms.organization.verification.model.OrganizationVerificationRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface OrganizationVerificationRequestRepository
        extends JpaRepository<OrganizationVerificationRequest, Long> {

    boolean existsByOrganizationIdAndStatus(
            Long organizationId,
            OrganizationVerificationStatus status
    );

    Page<OrganizationVerificationRequest> findAllByStatusOrderByCreatedAtDesc(
            OrganizationVerificationStatus status,
            Pageable pageable
    );

    Page<OrganizationVerificationRequest> findAllByOrderByCreatedAtDesc(
            Pageable pageable
    );

    Page<OrganizationVerificationRequest> findAllByOrganizationIdOrderByCreatedAtDesc(
            Long organizationId,
            Pageable pageable
    );

    @Query("""
            select request
            from OrganizationVerificationRequest request
            join fetch request.organization
            join fetch request.requestedBy
            left join fetch request.reviewedBy
            where request.id = :requestId
            """)
    Optional<OrganizationVerificationRequest> findByIdWithDetails(
            @Param("requestId") Long requestId
    );
}
