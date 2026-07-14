package app.lms.media.repository;

import app.lms.media.model.PostMedia;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PostMediaRepository extends JpaRepository<PostMedia,Long> {
    Page<PostMedia> findAllByOrganizationIdOrderByCreatedAtDesc(
            Long OrganizationId,
            Pageable pageable
    );

    boolean existsByOrganizationIdAndNameIgnoreCase(
            Long OrganizationId,
            String name
    );

    boolean existsByOrganizationIdAndNameIgnoreCaseAndIdNot(
            Long OrganizationId,
            String name,
            Long mediaId
    );
}
