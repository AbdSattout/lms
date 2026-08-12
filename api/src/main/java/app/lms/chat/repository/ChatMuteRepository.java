package app.lms.chat.repository;

import app.lms.chat.model.ChatMute;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.Optional;

public interface ChatMuteRepository
        extends JpaRepository<ChatMute, Long> {


    @Query("""
        SELECT m
        FROM ChatMute m
        WHERE m.user.id = :userId
          AND m.course.id = :courseId
          AND m.revokedAt IS NULL
          AND m.mutedUntil > :now
        ORDER BY m.createdAt DESC
    """)
    Optional<ChatMute> findActiveCourseMute(
            @Param("userId") Long userId,
            @Param("courseId") Long courseId,
            @Param("now") LocalDateTime now
    );

    @Query("""
        SELECT m
        FROM ChatMute m
        WHERE m.user.id = :userId
          AND m.conversation.id = :conversationId
          AND m.revokedAt IS NULL
          AND m.mutedUntil > :now
        ORDER BY m.createdAt DESC
    """)
    Optional<ChatMute> findActiveConversationMute(
            @Param("userId") Long userId,
            @Param("conversationId") Long conversationId,
            @Param("now") LocalDateTime now
    );

    @Query("""
    SELECT m
    FROM ChatMute m
    WHERE m.user.id = :userId
      AND m.course.id = :courseId
      AND m.revokedAt IS NULL
      AND m.mutedUntil > :now
""")
    Optional<ChatMute> findActiveMuteForCourse(
            @Param("userId") Long userId,
            @Param("courseId") Long courseId,
            @Param("now") LocalDateTime now
    );
}