UPDATE friend_requests
SET status = 'CANCELED',
    responded_at = COALESCE(responded_at, CURRENT_TIMESTAMP),
    updated_at = CURRENT_TIMESTAMP
WHERE id IN (
    SELECT id
    FROM (
        SELECT id,
               ROW_NUMBER() OVER (
                   PARTITION BY LEAST(sender_id, receiver_id),
                                GREATEST(sender_id, receiver_id)
                   ORDER BY created_at ASC NULLS LAST, id ASC
               ) AS row_number
        FROM friend_requests
        WHERE status = 'PENDING'
    ) ranked_requests
    WHERE row_number > 1
);

ALTER TABLE friend_requests
    DROP CONSTRAINT IF EXISTS uk_friend_requests_sender_receiver;

CREATE UNIQUE INDEX IF NOT EXISTS uk_friend_requests_pending_pair
    ON friend_requests (
        LEAST(sender_id, receiver_id),
        GREATEST(sender_id, receiver_id)
    )
    WHERE status = 'PENDING';
