package app.lms.badge.model;

import app.lms.common.model.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(
        name = "badges",
        uniqueConstraints = {
                @UniqueConstraint(
                        columnNames = "code"
                )
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Badge extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String code;

    @Column(nullable = false)
    private String title;

    @Column(length = 500)
    private String description;

    @Column(columnDefinition = "TEXT")
    private String iconUrl;

    @Column(nullable = false)
    private Integer sortOrder;

    @Column(nullable = false)
    private Boolean active;
}
