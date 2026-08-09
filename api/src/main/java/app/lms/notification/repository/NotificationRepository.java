package app.lms.notification.repository;

import app.lms.notification.model.Notification;
import app.lms.notification.enums.NotificationType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface NotificationRepository
        extends JpaRepository<Notification, Long> {

    Page<Notification> findAllByUserIdOrderByCreatedAtDesc(
            Long userId,
            Pageable pageable
    );

    @Query("""
            select notification
            from Notification notification
            where notification.user.id = :userId
            and not (
                notification.type = :organizationInviteType
                and notification.referenceType = 'ORGANIZATION'
                and exists (
                    select member.id
                    from OrganizationMember member
                    where member.organization.id = notification.referenceId
                    and member.user.id = :userId
                )
            )
            order by notification.createdAt desc
            """)
    Page<Notification> findVisibleByUserIdOrderByCreatedAtDesc(
            @Param("userId") Long userId,
            @Param("organizationInviteType") NotificationType organizationInviteType,
            Pageable pageable
    );

    long countByUserIdAndReadFalse(
            Long userId
    );

    @Query("""
            select count(notification)
            from Notification notification
            where notification.user.id = :userId
            and notification.read = false
            and not (
                notification.type = :organizationInviteType
                and notification.referenceType = 'ORGANIZATION'
                and exists (
                    select member.id
                    from OrganizationMember member
                    where member.organization.id = notification.referenceId
                    and member.user.id = :userId
                )
            )
            """)
    long countVisibleUnreadByUserId(
            @Param("userId") Long userId,
            @Param("organizationInviteType") NotificationType organizationInviteType
    );

    Optional<Notification> findByIdAndUserId(
            Long id,
            Long userId
    );
}
