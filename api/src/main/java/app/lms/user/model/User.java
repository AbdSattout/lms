package app.lms.user.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "users")
public class User {


    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private String username;
    @Column(columnDefinition = "TEXT")
    private String picture;
    private String pictureFileId;
    private String email;
    @Column(unique = true)
    private String telegramId;
    @Column(unique = true)
    private String googleId;


}
