package app.lms.repository;

import app.lms.model.Profile;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ProfileRepositry extends JpaRepository<Profile , Long> {
    Optional<Profile> findByUserId (long id );
}
