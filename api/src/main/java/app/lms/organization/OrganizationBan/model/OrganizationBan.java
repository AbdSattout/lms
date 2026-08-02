package app.lms.organization.OrganizationBan.model;

import app.lms.admin.model.Admin;
import app.lms.common.model.BaseEntity;
import app.lms.organization.model.Organization;
import app.lms.user.model.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "organization_bans",
        uniqueConstraints = @UniqueConstraint(
                columnNames = {
                        "organization_id",
                        "user_id"
                }
        )
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrganizationBan extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(nullable = false)
    private Organization organization;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(nullable = true)
    private Admin bannedByAppAdmins;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(nullable = true)
    private User bannedByOrgAdmins;

    @Column(columnDefinition = "TEXT")
    private String reason;

    @Column(name = "expires_at")
    private LocalDateTime expiresAt;
}
