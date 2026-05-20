package app.lms.service;

import app.lms.dto.ProfileResponse;
import app.lms.dto.UpdateProfile;
import app.lms.model.Profile;
import app.lms.model.User;
import app.lms.repository.ProfileRepositry;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ProfileService {

    private final ProfileRepositry profileRepository;

    public ProfileResponse getMyProfile(User user) {

        Profile profile = profileRepository
                .findByUserId(user.getId())
                .orElseGet(() -> createEmptyProfile(user));

        return mapToResponse(user, profile);
    }

    @Transactional
    public ProfileResponse updateProfile(UpdateProfile request , User user) {


        Profile profile = profileRepository
                .findByUserId(user.getId())
                .orElseThrow(() -> new UsernameNotFoundException("Profile Not Found"));

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
    public void deleteProfile(User user ) {

        profileRepository.findByUserId(user.getId())
                .ifPresent(profileRepository::delete);
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
