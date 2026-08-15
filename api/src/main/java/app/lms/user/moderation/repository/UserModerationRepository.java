package app.lms.user.moderation.repository;

import app.lms.user.moderation.model.UserModeration;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface UserModerationRepository
        extends JpaRepository<UserModeration, Long> {

    @Query("""
            select case when count(moderation) > 0 then true else false end
            from UserModeration moderation
            where moderation.user.id = :userId
            and (
                moderation.expiresAt is null
                or moderation.expiresAt > CURRENT_TIMESTAMP
            )
            """)
    boolean existsActiveByUserId(
            @Param("userId") Long userId
    );

    Optional<UserModeration> findByUserId(
            Long userId
    );

    @Query(
            value = """
                    select moderation
                    from UserModeration moderation
                    join fetch moderation.user
                    join fetch moderation.bannedBy
                    where moderation.expiresAt is null
                    or moderation.expiresAt > CURRENT_TIMESTAMP
                    order by moderation.createdAt desc
                    """,
            countQuery = """
                    select count(moderation)
                    from UserModeration moderation
                    where moderation.expiresAt is null
                    or moderation.expiresAt > CURRENT_TIMESTAMP
                    """
    )
    Page<UserModeration> findAllActive(
            Pageable pageable
    );
}
