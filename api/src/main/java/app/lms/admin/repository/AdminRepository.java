package app.lms.admin.repository;

import app.lms.admin.model.Admin;
import app.lms.admin.enums.AdminRole;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface AdminRepository extends JpaRepository<Admin, Long> {

    Optional<Admin> findByEmailIgnoreCase(
            String email
    );

    boolean existsByEmailIgnoreCase(
            String email
    );

    Page<Admin> findAllByRole(
            AdminRole role,
            Pageable pageable
    );

    List<Admin> findAllBySeededTrue();
}
