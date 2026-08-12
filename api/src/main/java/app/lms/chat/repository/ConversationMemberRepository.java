package app.lms.chat.repository;

import app.lms.chat.model.ConversationMember;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ConversationMemberRepository
        extends JpaRepository<ConversationMember, Long> {

    Optional<ConversationMember>
    findByConversationIdAndUserId(
            Long conversationId,
            Long userId
    );

    boolean existsByConversationIdAndUserId(
            Long conversationId,
            Long userId
    );

    List<ConversationMember>
    findAllByConversationId(Long conversationId);
}