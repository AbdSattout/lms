package app.lms.user.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class UserSearchResponse {

    private Long id;

    private String name;

    private String username;

    private String picture;

    private String email;
}
