package app.lms.admin.dto;

public record AdminAuthResponse(
        String token,
        AdminResponse admin
) {
}
