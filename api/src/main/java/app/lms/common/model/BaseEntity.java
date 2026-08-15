package app.lms.common.model;

import jakarta.persistence.MappedSuperclass;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Column;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Getter
@Setter
@MappedSuperclass
public abstract class BaseEntity {

    @Column(columnDefinition = "timestamp(6) with time zone")
    private Instant createdAt;

    @Column(columnDefinition = "timestamp(6) with time zone")
    private Instant updatedAt;

    @PrePersist
    public void onCreate() {
        Instant now =
                Instant.now();

        createdAt = now;
        updatedAt = now;
    }

    @PreUpdate
    public void onUpdate() {
        updatedAt = Instant.now();
    }

}
