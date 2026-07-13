package app.lms.organization.repository;

import app.lms.organization.enums.JoinRequestStatus;
import app.lms.organization.model.OrganizationJoinRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface OrganizationJoinRequestRepository extends JpaRepository<OrganizationJoinRequest, Long> {

    boolean existsByOrganizationIdAndUserIdAndStatus(
            Long organizationId,
            Long userId,
            JoinRequestStatus status
    );

    List<OrganizationJoinRequest> findAllByOrganizationIdAndStatusOrderByCreatedAtDesc(
            Long organizationId,
            JoinRequestStatus status
    );

    Optional<OrganizationJoinRequest> findByOrganizationIdAndUserIdAndStatus(
            Long organizationId,
            Long userId,
            JoinRequestStatus status
    );
}
