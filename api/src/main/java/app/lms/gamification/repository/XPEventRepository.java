package app.lms.gamification.repository;

import app.lms.gamification.enums.XPEventType;
import app.lms.gamification.model.XPEvent;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface XPEventRepository
        extends JpaRepository<XPEvent, Long> {

    List<XPEvent>
    findAllByUserIdOrderByCreatedAtDesc(
            Long userId
    );

    List<XPEvent>
    findAllByUserIdAndType(
            Long userId,
            XPEventType type
    );

    Optional<XPEvent> findByUserIdAndTypeAndReferenceId(
            Long userId,
            XPEventType type,
            Long referenceId
    );
}
