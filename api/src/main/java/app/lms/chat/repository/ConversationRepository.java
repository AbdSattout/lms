package app.lms.chat.repository;

import app.lms.chat.enums.ConversationType;
import app.lms.chat.model.Conversation;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ConversationRepository
        extends JpaRepository<Conversation, Long> {

    Optional<Conversation> findByCourseId(Long courseId);

    Optional<Conversation>
    findByTypeAndDirectUserOneIdAndDirectUserTwoId(
            ConversationType type,
            Long directUserOneId,
            Long directUserTwoId
    );
}
