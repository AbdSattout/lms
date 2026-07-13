package app.lms.roadmap.repository;

import app.lms.roadmap.model.Roadmap;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RoadmapRepository extends JpaRepository<Roadmap, Long> {

    Optional<Roadmap> findByOrganizationId(
            Long organizationId
    );

    boolean existsByOrganizationId(
            Long organizationId
    );
}
