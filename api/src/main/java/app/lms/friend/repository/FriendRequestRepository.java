package app.lms.friend.repository;

import app.lms.friend.enums.FriendRequestStatus;
import app.lms.friend.model.FriendRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;


public interface FriendRequestRepository
        extends JpaRepository<FriendRequest, Long> {

    Page<FriendRequest> findAllBySenderIdAndStatus(
            Long senderId,
            FriendRequestStatus status,
            Pageable pageable
    );

    boolean existsBySenderIdAndReceiverIdAndStatus(
            Long senderId,
            Long receiverId,
            FriendRequestStatus status
    );

    Page<FriendRequest> findAllByReceiverIdAndStatus(
            Long receiverId,
            FriendRequestStatus status,
            Pageable pageable
    );

}
