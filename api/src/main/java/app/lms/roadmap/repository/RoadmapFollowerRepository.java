package app.lms.roadmap.repository;

import app.lms.roadmap.model.RoadmapFollower;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RoadmapFollowerRepository
        extends JpaRepository<RoadmapFollower, Long> {

    boolean existsByRoadmapIdAndUserId(
            Long roadmapId,
            Long userId
    );

    Optional<RoadmapFollower> findByRoadmapIdAndUserId(
            Long roadmapId,
            Long userId
    );

    Page<RoadmapFollower> findAllByUserIdOrderByCreatedAtDesc(
            Long userId,
            Pageable pageable
    );
}
