package app.lms.admin.mapper;

import app.lms.admin.dto.AdminResponse;
import app.lms.admin.model.Admin;
import org.springframework.stereotype.Component;

@Component
public class AdminMapper {

    public AdminResponse toResponse(
            Admin admin
    ) {

        return new AdminResponse(
                admin.getId(),
                admin.getName(),
                admin.getEmail(),
                admin.getRole(),
                admin.getEnabled()
        );
    }
}
