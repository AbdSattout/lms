package app.lms.friend.controller;

import app.lms.friend.dto.FriendActionResponse;
import app.lms.friend.dto.FriendRequestResponse;
import app.lms.friend.dto.FriendResponse;
import app.lms.friend.service.FriendService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/friends")
@RequiredArgsConstructor
public class FriendController {

    private final FriendService friendService;

    @PostMapping("/requests/{userId}")
    public ResponseEntity<Void> sendRequest(

            @PathVariable Long userId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        friendService.sendRequest(
                userId,
                principal.user()
        );

        return ResponseEntity.ok().build();
    }

    @PatchMapping("/requests/{requestId}/accept")
    public ResponseEntity<FriendActionResponse> accept(

            @PathVariable Long requestId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                friendService.accept(
                        requestId,
                        principal.user()
                )
        );
    }

    @PatchMapping("/requests/{requestId}/reject")
    public ResponseEntity<Void> reject(

            @PathVariable Long requestId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        friendService.reject(
                requestId,
                principal.user()
        );

        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/requests/{requestId}")
    public ResponseEntity<Void> cancel(

            @PathVariable Long requestId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        friendService.cancel(
                requestId,
                principal.user()
        );

        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{friendId}")
    public ResponseEntity<Void> removeFriend(

            @PathVariable Long friendId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        friendService.removeFriend(
                friendId,
                principal.user()
        );

        return ResponseEntity.ok().build();
    }

    @GetMapping
    public ResponseEntity<Page<FriendResponse>> getFriends(

            Pageable pageable,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                friendService.getFriends(
                        principal.user(),
                        pageable
                )
        );
    }

    @GetMapping("/requests/received")
    public ResponseEntity<Page<FriendRequestResponse>> getReceivedRequests(

            Pageable pageable,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                friendService.getReceivedRequests(
                        principal.user(),
                        pageable
                )
        );
    }

    @GetMapping("/requests/sent")
    public ResponseEntity<Page<FriendRequestResponse>> getSentRequests(

            Pageable pageable,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                friendService.getSentRequests(
                        principal.user(),
                        pageable
                )
        );
    }

}
