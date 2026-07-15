package app.lms.gamification.repository;

import app.lms.gamification.enums.XPEventType;
import app.lms.gamification.model.XPEvent;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

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

    boolean existsByUserIdAndTypeAndReferenceId(
            Long userId,
            XPEventType type,
            Long referenceId
    );
}
