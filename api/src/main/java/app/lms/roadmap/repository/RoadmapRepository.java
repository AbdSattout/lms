package app.lms.roadmap.repository;

import app.lms.roadmap.model.Roadmap;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RoadmapRepository extends JpaRepository<Roadmap, Long> {

    Optional<Roadmap> findByIdAndOrganizationId(
            Long roadmapId,
            Long organizationId
    );

    Page<Roadmap> findAllByOrganizationIdOrderByCreatedAtDesc(
            Long organizationId,
            Pageable pageable
    );

    Page<Roadmap> findAllByOrderByCreatedAtDesc(
            Pageable pageable
    );

    void deleteByOrganizationId(
            Long organizationId
    );
}
