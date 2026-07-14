package app.lms.media.repository;

import app.lms.media.model.OrganizationMedia;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface OrganizationMediaRepository extends JpaRepository<OrganizationMedia, Long> {

    Page<OrganizationMedia> findAllByOrganizationIdOrderByCreatedAtDesc(
            Long organizationId,
            Pageable pageable
    );

    boolean existsByOrganizationIdAndNameIgnoreCase(
            Long organizationId,
            String name
    );

    boolean existsByOrganizationIdAndNameIgnoreCaseAndIdNot(
            Long organizationId,
            String name,
            Long mediaId
    );

    long countByOrganizationId(
            Long organizationId
    );

    @Query("""
            select coalesce(sum(media.sizeBytes), 0)
            from OrganizationMedia media
            where media.organization.id = :organizationId
            """)
    long sumSizeBytesByOrganizationId(
            Long organizationId
    );
}
