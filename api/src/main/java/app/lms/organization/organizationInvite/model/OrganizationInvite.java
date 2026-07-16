package app.lms.organization.organizationInvite.model;

import app.lms.common.model.BaseEntity;
import app.lms.organization.model.Organization;
import app.lms.organization.organizationInvite.enums.InviteStatus;
import app.lms.organization.enums.Role;
import app.lms.user.model.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "organization_invites")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrganizationInvite extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "organization_id")
    private Organization organization;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = true)
    private User user;

    @Enumerated(EnumType.STRING)
    private Role role;

    @Column(nullable =false, unique = true)
    private String token;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "invited_by")
    private User invitedBy;

    @Enumerated(EnumType.STRING)
    private InviteStatus status;

    private Integer maxUses;

    @Builder.Default
    private int usedCount = 0;

    private LocalDateTime expiresAt;

    private LocalDateTime acceptedAt;

    private LocalDateTime createdAt;



}
