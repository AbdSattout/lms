package app.lms.chat.repository;

import app.lms.chat.model.ConversationMember;
import app.lms.chat.model.Message;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface MessageRepository
        extends JpaRepository<Message, Long> {

    Page<Message> findAllByConversationIdOrderByCreatedAtDesc(
            Long conversationId,
            Pageable pageable
    );

    Optional<Message>
    findByIdAndConversationId(
            Long messageId,
            Long conversationId
    );

}