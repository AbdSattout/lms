package app.lms.friend.repository;

import app.lms.friend.enums.FriendRequestStatus;
import app.lms.friend.model.FriendRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;


public interface FriendRequestRepository
        extends JpaRepository<FriendRequest, Long> {

    Page<FriendRequest> findAllBySenderIdAndStatus(
            Long senderId,
            FriendRequestStatus status,
            Pageable pageable
    );

    @Query("""
            SELECT COUNT(request) > 0
            FROM FriendRequest request
            WHERE request.status = :status
              AND (
                    (
                        request.sender.id = :userId
                        AND request.receiver.id = :otherUserId
                    )
                    OR
                    (
                        request.sender.id = :otherUserId
                        AND request.receiver.id = :userId
                    )
              )
            """)
    boolean existsBetweenUsersAndStatus(
            @Param("userId")
            Long userId,

            @Param("otherUserId")
            Long otherUserId,

            @Param("status")
            FriendRequestStatus status
    );

    @Query("""
            SELECT request
            FROM FriendRequest request
            WHERE request.status = :status
              AND (
                    (
                        request.sender.id = :userId
                        AND request.receiver.id = :otherUserId
                    )
                    OR
                    (
                        request.sender.id = :otherUserId
                        AND request.receiver.id = :userId
                    )
              )
            """)
    Optional<FriendRequest> findBetweenUsersAndStatus(
            @Param("userId")
            Long userId,

            @Param("otherUserId")
            Long otherUserId,

            @Param("status")
            FriendRequestStatus status
    );

    Page<FriendRequest> findAllByReceiverIdAndStatus(
            Long receiverId,
            FriendRequestStatus status,
            Pageable pageable
    );

}
