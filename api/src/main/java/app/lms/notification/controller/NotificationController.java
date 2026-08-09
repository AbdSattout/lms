package app.lms.notification.controller;

import app.lms.notification.dto.NotificationResponse;
import app.lms.notification.service.NotificationService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    public Page<NotificationResponse> getMyNotifications(
            @AuthenticationPrincipal UserPrincipal principal,
            Pageable pageable
    ) {

        return notificationService.getMyNotifications(
                principal.user(),
                pageable
        );
    }

    @GetMapping("/unread-count")
    public void getUnreadCount(
            @AuthenticationPrincipal UserPrincipal principal
    ) {

         notificationService.getUnreadCount(
                principal.user()
        );
    }

    @PatchMapping("/{id}/read")
    public void markAsRead(
            @PathVariable Long id,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        notificationService.markAsRead(
                id,
                principal.user()
        );
    }

    @PatchMapping("/read-all")
    public void markAllAsRead(
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        notificationService.markAllAsRead(
                principal.user()
        );
    }
}
