package app.lms.chat.repository;

import app.lms.chat.enums.ConversationType;
import app.lms.chat.model.Conversation;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface ConversationRepository
        extends JpaRepository<Conversation, Long> {

    Optional<Conversation> findByCourseId(
            Long courseId
    );

    Optional<Conversation>
    findByTypeAndDirectUserOneIdAndDirectUserTwoId(
            ConversationType type,
            Long directUserOneId,
            Long directUserTwoId
    );

    @Query(
            value = """
                    select conversation
                    from Conversation conversation
                    left join fetch conversation.directUserOne userOne
                    left join fetch conversation.directUserTwo userTwo
                    where conversation.type = :directType
                    and (
                        userOne.id = :userId
                        or userTwo.id = :userId
                    )
                    order by coalesce(
                        conversation.lastMessageAt,
                        conversation.createdAt
                    ) desc
                    """,

            countQuery = """
                    select count(conversation)
                    from Conversation conversation
                    where conversation.type = :directType
                    and (
                        conversation.directUserOne.id = :userId
                        or conversation.directUserTwo.id = :userId
                    )
                    """
    )
    Page<Conversation> findDirectByUserId(
            @Param("userId")
            Long userId,

            @Param("directType")
            ConversationType directType,

            Pageable pageable
    );
}