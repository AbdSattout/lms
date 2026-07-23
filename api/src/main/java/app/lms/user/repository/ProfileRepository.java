package app.lms.user.repository;

import app.lms.user.model.Profile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProfileRepository extends JpaRepository<Profile , Long> {
    Optional<Profile> findByUserId (long id );
    @Query("""
        select p
        from Profile p
        join fetch p.user u
        where
            lower(u.name) like lower(concat('%', :q, '%'))
            or
            lower(u.username) like lower(concat('%', :usernameQ, '%'))
            or
            lower(p.email) like lower(concat('%', :q, '%'))
        order by u.name
    """)
    List<Profile> search(
            @Param("q") String q,
            @Param("usernameQ") String usernameQ
    );
}

