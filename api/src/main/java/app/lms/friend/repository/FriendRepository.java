package app.lms.friend.repository;

import app.lms.friend.model.Friend;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;


public interface FriendRepository extends JpaRepository<Friend, Long> {

    boolean existsByUser1IdAndUser2Id(
            Long user1Id,
            Long user2Id
    );

    java.util.Optional<Friend> findByUser1IdAndUser2Id(
            Long user1Id,
            Long user2Id
    );


    @Query("""
            SELECT f
            FROM Friend f
            WHERE f.user1.id = :userId
               OR f.user2.id = :userId
            """)
    Page<Friend> findAllByUserId(
            Long userId,
            Pageable pageable
    );

    @Query("""
            SELECT COUNT(friend)
            FROM Friend friend
            WHERE friend.user1.id = :userId
               OR friend.user2.id = :userId
            """)
    long countByUserId(
            Long userId
    );

}
