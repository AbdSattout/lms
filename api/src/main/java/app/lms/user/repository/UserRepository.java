package app.lms.user.repository;

import app.lms.user.model.User;
import app.lms.user.repository.projection.UserSearchRow;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByTelegramId(
            String telegramId
    );

    Optional<User> findByGoogleId(
            String googleId
    );

    Optional<User> findByEmailIgnoreCase(
            String email
    );

    boolean existsByUsernameIgnoreCaseAndIdNot(
            String username,
            Long id
    );

    boolean existsByEmailIgnoreCaseAndIdNot(
            String email,
            Long id
    );

    @Query("""
            select u as user, p as profile
            from User u
            left join Profile p
                on p.user = u
            where
                lower(u.name) like lower(concat('%', :q, '%'))
                or lower(u.username) like lower(concat('%', :usernameQ, '%'))
                or lower(p.email) like lower(concat('%', :q, '%'))
            order by u.name
            """)
    List<UserSearchRow> searchWithProfile(
            @Param("q") String q,
            @Param("usernameQ") String usernameQ
    );

    @Query(
            value = """
                    select u.*
                    from users u
                    left join profiles p
                        on p.user_id = u.id
                    where
                        lower(coalesce(u.name, '')) like lower(concat('%', :q, '%'))
                        or (
                            :usernameQ <> ''
                            and lower(coalesce(u.username, '')) like lower(concat('%', :usernameQ, '%'))
                        )
                        or lower(coalesce(u.email, '')) like lower(concat('%', :q, '%'))
                        or lower(coalesce(p.email, '')) like lower(concat('%', :q, '%'))
                        or lower(coalesce(p.phone, '')) like lower(concat('%', :q, '%'))
                        or lower(coalesce(p.university, '')) like lower(concat('%', :q, '%'))
                        or lower(coalesce(u.name, '')) % lower(:q)
                        or (
                            :usernameQ <> ''
                            and lower(coalesce(u.username, '')) % lower(:usernameQ)
                        )
                        or lower(coalesce(u.email, '')) % lower(:q)
                        or lower(coalesce(p.email, '')) % lower(:q)
                        or lower(coalesce(p.phone, '')) % lower(:q)
                        or lower(coalesce(p.university, '')) % lower(:q)
                        or similarity(lower(coalesce(u.name, '')), lower(:q)) >= :threshold
                        or (
                            :usernameQ <> ''
                            and similarity(lower(coalesce(u.username, '')), lower(:usernameQ)) >= :threshold
                        )
                        or similarity(lower(coalesce(u.email, '')), lower(:q)) >= :threshold
                        or similarity(lower(coalesce(p.email, '')), lower(:q)) >= :threshold
                        or similarity(lower(coalesce(p.phone, '')), lower(:q)) >= :threshold
                        or similarity(lower(coalesce(p.university, '')), lower(:q)) >= :threshold
                    order by greatest(
                        similarity(lower(coalesce(u.name, '')), lower(:q)),
                        case
                            when :usernameQ <> ''
                                then similarity(lower(coalesce(u.username, '')), lower(:usernameQ))
                            else 0
                        end,
                        similarity(lower(coalesce(u.email, '')), lower(:q)),
                        similarity(lower(coalesce(p.email, '')), lower(:q)),
                        similarity(lower(coalesce(p.phone, '')), lower(:q)),
                        similarity(lower(coalesce(p.university, '')), lower(:q))
                    ) desc, u.id desc
                    """,
            countQuery = """
                    select count(*)
                    from users u
                    left join profiles p
                        on p.user_id = u.id
                    where
                        lower(coalesce(u.name, '')) like lower(concat('%', :q, '%'))
                        or (
                            :usernameQ <> ''
                            and lower(coalesce(u.username, '')) like lower(concat('%', :usernameQ, '%'))
                        )
                        or lower(coalesce(u.email, '')) like lower(concat('%', :q, '%'))
                        or lower(coalesce(p.email, '')) like lower(concat('%', :q, '%'))
                        or lower(coalesce(p.phone, '')) like lower(concat('%', :q, '%'))
                        or lower(coalesce(p.university, '')) like lower(concat('%', :q, '%'))
                        or lower(coalesce(u.name, '')) % lower(:q)
                        or (
                            :usernameQ <> ''
                            and lower(coalesce(u.username, '')) % lower(:usernameQ)
                        )
                        or lower(coalesce(u.email, '')) % lower(:q)
                        or lower(coalesce(p.email, '')) % lower(:q)
                        or lower(coalesce(p.phone, '')) % lower(:q)
                        or lower(coalesce(p.university, '')) % lower(:q)
                        or similarity(lower(coalesce(u.name, '')), lower(:q)) >= :threshold
                        or (
                            :usernameQ <> ''
                            and similarity(lower(coalesce(u.username, '')), lower(:usernameQ)) >= :threshold
                        )
                        or similarity(lower(coalesce(u.email, '')), lower(:q)) >= :threshold
                        or similarity(lower(coalesce(p.email, '')), lower(:q)) >= :threshold
                        or similarity(lower(coalesce(p.phone, '')), lower(:q)) >= :threshold
                        or similarity(lower(coalesce(p.university, '')), lower(:q)) >= :threshold
                    """,
            nativeQuery = true
    )
    Page<User> searchForAdmin(
            @Param("q") String q,
            @Param("usernameQ") String usernameQ,
            @Param("threshold") double threshold,
            Pageable pageable
    );
    @Query("""
    select u as user, p as profile
    from User u
    left join Profile p
        on p.user = u
    where u.id = :id
""")
    Optional<UserSearchRow> findUserWithProfileById(
            @Param("id") Long id
    );
}
