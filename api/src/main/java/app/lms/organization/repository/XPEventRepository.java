package app.lms.organization.repository;

import app.lms.courceEnrollment.enums.XPEventType;
import app.lms.organization.model.XPEvent;
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
}
