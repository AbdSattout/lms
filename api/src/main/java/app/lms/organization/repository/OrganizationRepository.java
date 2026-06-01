package app.lms.organization.repository;

import app.lms.organization.model.Organization;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface OrganizationRepository extends JpaRepository<Organization, Long> {

    boolean existsByNameIgnoreCase(String name);

    boolean existsBySlug(String slug);

    Optional<Organization> findBySlug(String slug);
}
