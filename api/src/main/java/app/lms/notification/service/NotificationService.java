package app.lms.notification.service;


import app.lms.course.model.Course;
import app.lms.enrollment.enums.EnrollmentStatus;
import app.lms.enrollment.model.CourseEnrollment;
import app.lms.enrollment.repository.CourseEnrollmentRepository;
import app.lms.notification.dto.NotificationResponse;
import app.lms.notification.enums.NotificationType;
import app.lms.notification.event.NotificationCreatedEvent;
import app.lms.notification.mapper.NotificationMapper;
import app.lms.notification.model.Notification;
import app.lms.notification.repository.NotificationRepository;
import app.lms.organization.enums.Role;
import app.lms.organization.model.Organization;
import app.lms.organization.model.OrganizationMember;
import app.lms.organization.repository.OrganizationMemberRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Transactional
@Slf4j
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final NotificationMapper notificationMapper;
    private final ApplicationEventPublisher applicationEventPublisher;
    private final OrganizationMemberRepository organizationMemberRepository;
    private final CourseEnrollmentRepository courseEnrollmentRepository;

    public NotificationResponse create(
            User user,
            NotificationType type,
            String title,
            String message,
            String referenceType,
            Long referenceId
    ) {

        Notification notification =
                Notification.builder()
                        .user(user)
                        .type(type)
                        .title(title)
                        .message(message)
                        .referenceType(referenceType)
                        .referenceId(referenceId)
                        .read(false)
                        .build();

        notificationRepository.save(notification);

        log.info(
                "Notification created. notificationId={}, userId={}, type={}, referenceType={}, referenceId={}",
                notification.getId(),
                user.getId(),
                type,
                referenceType,
                referenceId
        );

        applicationEventPublisher.publishEvent(
                new NotificationCreatedEvent(
                        notification.getId()
                )
        );

        log.info(
                "Notification push event published. notificationId={}",
                notification.getId()
        );

        return notificationMapper.toResponse(notification);
    }

    @Transactional()
    public Page<NotificationResponse> getMyNotifications(
            User user,
            Pageable pageable
    ) {

        return notificationRepository
                .findVisibleByUserIdOrderByCreatedAtDesc(
                        user.getId(),
                        NotificationType.ORGANIZATION_INVITE,
                        pageable
                )
                .map(notificationMapper::toResponse);
    }

    @Transactional()
    public long getUnreadCount(
            User user
    ) {
        return notificationRepository
                .countVisibleUnreadByUserId(
                        user.getId(),
                        NotificationType.ORGANIZATION_INVITE
                );
    }

    public void markAsRead(
            Long notificationId,
            User user
    ) {

        Notification notification =
                notificationRepository
                        .findByIdAndUserId(
                                notificationId,
                                user.getId()
                        )
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "Notification not found"
                                )
                        );

        if (!notification.isRead()) {

            notification.setRead(true);
            notification.setReadAt(LocalDateTime.now());
        }
    }

    public void markAllAsRead(
            User user
    ) {

        Page<Notification> notifications =
                notificationRepository
                        .findAllByUserIdOrderByCreatedAtDesc(
                                user.getId(),
                                Pageable.unpaged()
                        );

        LocalDateTime now = LocalDateTime.now();

        notifications.forEach(notification -> {

            if (!notification.isRead()) {

                notification.setRead(true);
                notification.setReadAt(now);
            }
        });
    }

    @Transactional
    public void notifyOrganizationStudents(
            Organization organization,
            NotificationType type,
            String title,
            String message,
            String referenceType,
            Long referenceId
    ) {
        Pageable pageable = PageRequest.of(0, 20);

        Page<OrganizationMember> members =
                organizationMemberRepository
                        .findByOrganizationIdAndRole(
                                organization.getId(),
                                Role.STUDENT,
                                pageable

                        );

        for (OrganizationMember member : members) {

            create(
                    member.getUser(),
                    type,
                    title,
                    message,
                    referenceType,
                    referenceId
            );
        }
    }
    @Transactional
    public void notifyOrganizationAdmin(
            Organization organization,
            NotificationType type,
            String title,
            String message,
            String referenceType,
            Long referenceId
    ) {
        Pageable pageable = PageRequest.of(0, 20);

        Page<OrganizationMember> admins =
                organizationMemberRepository
                        .findByOrganizationIdAndRole(
                                organization.getId(),
                                Role.ADMIN,
                                pageable

                        );
        create(
                organization.getOwner(),
                type,
                title,
                message,
                referenceType,
                referenceId
        );

        for (OrganizationMember admin : admins) {

            create(
                    admin.getUser(),
                    type,
                    title,
                    message,
                    referenceType,
                    referenceId
            );
        }
    }

    @Transactional
    public void notifyCourseMember(
            Course course,
            NotificationType type,
            String title,
            String message,
            String referenceType,
            Long referenceId
    ) {
        Pageable pageable = PageRequest.of(0, 20);

        Page<CourseEnrollment> members =
                courseEnrollmentRepository
                        .findAllByCourseIdAndStatus(
                                course.getId(),
                                EnrollmentStatus.ACTIVE,
                                pageable

                        );

        for (CourseEnrollment member : members) {

            create(
                    member.getUser(),
                    type,
                    title,
                    message,
                    referenceType,
                    referenceId
            );
        }
    }
}
