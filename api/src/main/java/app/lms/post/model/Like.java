package app.lms.post.model;

import app.lms.post.enums.LikeTargetType;
import app.lms.post.enums.ReactionType;
import app.lms.user.model.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;

@Entity(name = "UserLike")
@Table(
        name = "likes",
        uniqueConstraints = {
                @UniqueConstraint(
                        columnNames = {
                                "post_id",
                                "user_id"
                        }
                ),
                @UniqueConstraint(
                        columnNames = {
                                "comment_id",
                                "user_id"
                        }
                )
        }
)
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Like {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private LikeTargetType targetType;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "post_id")
    private Post post;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "comment_id")
    private Comment comment;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    @Builder.Default
    private ReactionType reactionType = ReactionType.LIKE;

    @CreationTimestamp
    @Column(columnDefinition = "timestamp(6) with time zone")
    private Instant createdAt;

    @PrePersist
    @PreUpdate
    void validateTarget() {

        if (reactionType == null) {
            reactionType = ReactionType.LIKE;
        }

        if (targetType == null) {
            if (post != null) {
                targetType = LikeTargetType.POST;
            } else if (comment != null) {
                targetType = LikeTargetType.COMMENT;
            }
        }

        if (targetType == LikeTargetType.POST &&
                (post == null || comment != null)) {
            throw new IllegalStateException(
                    "Post like must reference only a post"
            );
        }

        if (targetType == LikeTargetType.COMMENT &&
                (comment == null || post != null)) {
            throw new IllegalStateException(
                    "Comment like must reference only a comment"
            );
        }
    }
}
