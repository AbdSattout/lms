package app.lms.friend.controller;

import app.lms.friend.dto.FriendRequestResponse;
import app.lms.friend.dto.FriendResponse;
import app.lms.friend.service.FriendService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/friends")
@RequiredArgsConstructor
public class FriendController {

    private final FriendService friendService;

    @PostMapping("/requests/{userId}")
    public void sendRequest(
            @PathVariable Long userId,
            @AuthenticationPrincipal UserPrincipal user
    ) {
        friendService.sendRequest(userId, user.user());
    }

    @PatchMapping("/requests/{id}/accept")
    public void accept(
            @PathVariable Long id,
            @AuthenticationPrincipal UserPrincipal user
    ) {
        friendService.accept(id, user.user());
    }

    @PatchMapping("/requests/{id}/reject")
    public void reject(
            @PathVariable Long id,
            @AuthenticationPrincipal UserPrincipal user
    ) {
        friendService.reject(id, user.user());
    }

    @DeleteMapping("/requests/{id}")
    public void cancel(
            @PathVariable Long id,
            @AuthenticationPrincipal UserPrincipal user
    ) {
        friendService.cancel(id, user.user());
    }

    @DeleteMapping("/{friendId}")
    public void removeFriend(
            @PathVariable Long friendId,
            @AuthenticationPrincipal UserPrincipal user
    ) {
        friendService.removeFriend(friendId, user.user());
    }

    @GetMapping
    public Page<FriendResponse> getFriends(
            @AuthenticationPrincipal UserPrincipal user,
            Pageable pageable
    ) {
        return friendService.getFriends(
                user.user(),
                pageable
        );
    }

    @GetMapping("/requests/received")
    public Page<FriendRequestResponse> getReceivedRequests(
            @AuthenticationPrincipal UserPrincipal user,
            Pageable pageable
    ) {
        return friendService.getReceivedRequests(
                user.user(),
                pageable
        );
    }

    @GetMapping("/requests/sent")
    public Page<FriendRequestResponse> getSentRequests(
            @AuthenticationPrincipal UserPrincipal user,
            Pageable pageable
    ) {
        return friendService.getSentRequests(
                user.user(),
                pageable
        );
    }

}
