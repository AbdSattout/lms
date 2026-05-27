package app.lms.user.repository;

import app.lms.user.model.Profile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ProfileRepository extends JpaRepository<Profile , Long> {
    Optional<Profile> findByUserId (long id );
}
