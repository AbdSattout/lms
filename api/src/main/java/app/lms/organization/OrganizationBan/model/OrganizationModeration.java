package app.lms.organization.OrganizationBan.model;


import app.lms.admin.model.Admin;
import app.lms.common.model.BaseEntity;
import app.lms.organization.model.Organization;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "organization_moderation")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrganizationModeration extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    private Organization organization;

    @ManyToOne
    private Admin bannedBy;

    @Column(columnDefinition = "TEXT")
    private String reason;

    @Column(name = "expires_at")
    private LocalDateTime expiresAt;

}
