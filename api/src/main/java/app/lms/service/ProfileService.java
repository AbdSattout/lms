package app.lms.service;

import app.lms.dto.ProfileResponse;
import app.lms.dto.UpdateProfile;
import app.lms.model.Profile;
import app.lms.model.User;
import app.lms.repository.ProfileRepositry;
import app.lms.repository.UserRepository;
import app.lms.security.SecurityUtility;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ProfileService {

    private final ProfileRepositry profileRepository;
    private final UserRepository userRepository;

    public ProfileResponse getMyProfile() {

        User user = getCurrentUser();

        Profile profile = profileRepository
                .findByUserId(user.getId())
                .orElseGet(() -> createEmptyProfile(user));

        return mapToResponse(user, profile);
    }

    @Transactional
    public ProfileResponse updateProfile(UpdateProfile request) {

        User user = getCurrentUser();

        Profile profile = profileRepository
                .findByUserId(user.getId())
                .orElseGet(() -> createEmptyProfile(user));

        if (request.getEmail() != null) {
            profile.setEmail(request.getEmail());
        }

        if (request.getPhone() != null) {
            profile.setPhone(request.getPhone());
        }

        if (request.getUniversity() != null) {
            profile.setUniversity(request.getUniversity());
        }

        profileRepository.save(profile);

        return mapToResponse(user, profile);
    }

    @Transactional
    public void deleteProfile() {

        User user = getCurrentUser();

        profileRepository.findByUserId(user.getId())
                .ifPresent(profileRepository::delete);
    }

    private User getCurrentUser() {

        UserPrincipal principal = SecurityUtility.getCurrentUser();

        return userRepository.findByTelegramId(principal.getUsername())
                .orElseThrow();
    }

    private Profile createEmptyProfile(User user) {

        Profile profile = new Profile();

        profile.setUser(user);

        return profileRepository.save(profile);
    }

    private ProfileResponse mapToResponse(User user, Profile profile) {

        return ProfileResponse.builder()
                .name(user.getName())
                .email(profile.getEmail())
                .phone(profile.getPhone())
                .university(profile.getUniversity())
                .build();
    }

}
