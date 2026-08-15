package app.lms.badge.repository;

import app.lms.badge.model.Badge;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;

public interface BadgeRepository extends JpaRepository<Badge, Long> {

    List<Badge> findAllByActiveTrueOrderBySortOrderAsc();

    List<Badge> findAllByCodeInAndActiveTrue(
            Collection<String> codes
    );
}
