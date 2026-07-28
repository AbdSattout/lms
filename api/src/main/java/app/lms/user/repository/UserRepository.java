package app.lms.user.repository;

import app.lms.user.model.User;
import app.lms.user.repository.projection.UserSearchRow;
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
}
