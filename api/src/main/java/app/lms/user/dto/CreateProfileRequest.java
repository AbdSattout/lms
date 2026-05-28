package app.lms.user.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
public class CreateProfileRequest {
    private String email;
    private String phone;
    private String university;
}
