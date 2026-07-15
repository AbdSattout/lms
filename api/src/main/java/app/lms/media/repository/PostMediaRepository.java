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

    long countByOrganizationMediaId(
            Long organizationMediaId
    );
}
